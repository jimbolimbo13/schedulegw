class Scraper < ActiveRecord::Base
  # This holds a lot of the basic building blocks of scrapers.
  include ActiveModel::Model

  # Call this method to initialize a scrape of GWU's courses data. OK to call
  # this method repeatedly/often.
  def self.scrape_gwu!
    # return unless (Scraper.business_hours? && Rails.env == "production")

    school = School.find_by(name: "GWU")
    @semester = Semester.find_by(name: "spring2016")
    source = Scrapeurl.where(name: "crn", school:school, semester:@semester).first
    if source.source_changed?
      scraped_courses = Scraper.scrape_gwu_crn_pdf(source)
      Scraper.save_courses_to_db(scraped_courses)
      source.update_digest!
      source.update_last_scraped!
      school.crn_last_scraped = Time.now
    end
    source.last_checked = Time.now
    source.save!

    school.crn_last_checked = Time.now

    src = Scrapeurl.where(name: "exam", school:school, semester:@semester).first
    if src.source_changed?
      Scraper.scrape_gwu_exam_pdf!(src)
      src.update_digest!
      src.update_last_scraped!
      school.exam_last_scraped = Time.now
    end
    src.last_checked = Time.now
    src.save!

    school.exam_last_checked = Time.now
    school.save!

  end


  # Given an object from model Scrapeurls, this will go through it line-by-line and
  # return an array of model Course objects. This method does not save the objects
  # to the database.
  def self.scrape_gwu_crn_pdf(scrape_url_object)
    src = Yomu.new scrape_url_object.url
    @school = scrape_url_object.school.name
    @semester = scrape_url_object.semester

    course_array = Scraper.split_by_crns(src.text)

    scraped_courses = []
    course_array.each do |course_chunk|
      @course = nil
      @course = Scraper.parse_course_chunk(course_chunk)
      @course.semester_id = @semester.id
      @course.school = @school
      # @course.prof_id = Professorlist.assign_prof_id(@course)
      scraped_courses << @course
    end

    scraped_courses.reject! { |course| course.crn.nil? }

    return scraped_courses
  end

  # Fed chunks from the above one in the form of 5-digit start until the next
  # instance of 5-digits in a row (string)
  def self.parse_course_chunk(course_chunk)
    course_lines = course_chunk.split(/\n+/)
    @attributes = {}
    course_lines.each do |course_line|
      next if course_line.blank?
      next if course_line.empty?
      @attributes.merge!(Scraper.gwu_parse_crn_line(course_line))
    end
    @course = Course.new(@attributes)
    @course
  end

  # Splits the pdf and returns the parts between 5-digit bookends, including the first
  # 5-digit sequence (crn)
  def self.split_by_crns(text)
    nl_text = text.gsub(/\n/, "[newline]") # remove newlines but note their place
    courses_array = nl_text.split(/\[newline\]\s?(?=\d{5})/m) #split into strings starting with 5-digit strings but end before the next
    courses_array.map! { |c| c.gsub("[newline]", "\n")} # replace the newlines where they were.
    courses_array
  end

  # This actually commits the scraped courses to the database. This is separated
  # from the last step so we can easily test that the scraper is finding the correct
  # classes and returning them.
  def self.save_courses_to_db(courses_array)
    courses_array.each do |c|
      record = Course.find_or_initialize_by(crn: c.crn, semester_id: c.semester_id)
      attributes_to_write = c.attributes.select { |k, v| Scraper.scrape_attributes.include?(k) }
      attributes_to_write = attributes_to_write.reject { |k, v| k == "id" }
      attributes_to_write.each do |k, v|
        record.send("#{k}=", v) unless record.locked_attributes.include?("#{k}")
      end

      record.save! unless record.manual_lock == true
    end
  end

  # The list of attributes we may be able to change via scraping.
  def self.scrape_attributes
    [
      "crn",
      "gwid",
      "section",
      "course_name",
      "hours",
      "days",
      "day1_start",
      "day1_end",
      "day2_start",
      "day2_end",
      "day3_start",
      "day3_end",
      "day4_start",
      "day4_end",
      "day5_start",
      "day5_end",
      "day6_start",
      "day6_end",
      "day7_start",
      "day7_end",
      "llm_only",
      "jd_only",
      "course_name_2",
      "alt_schedule",
      "additional_info",
      "professor",
      "prof_id",
      "final_time",
      "final_date",
      "school"
    ]
  end

  # Returns an incomplete Course object with the attributes added as found in each line.
  # This is the method that decides what type of line it's fed.
  def self.gwu_parse_crn_line(line)
    @attrs = {}
    @class_time = nil
    @week_schedule_hash = nil
    case
    when Scraper.line_includes_crn?(line) # First line of a course listing.
      @attrs[:crn] = Scraper.parse_crn(line)
      @attrs[:gwid] = Scraper.parse_gwid(line)
      @attrs[:section] = Scraper.parse_section(line)
      @attrs[:course_name] = Scraper.parse_course_name(line)
      @attrs[:hours] = Scraper.parse_hours(line)
      @attrs[:days] = Scraper.parse_days(line)
      @class_time = Scraper.parse_times(line) # Type array returned, or string "TBA"
      @week_schedule_hash = Scraper.assign_times_to_days(@attrs[:days], @class_time) unless @class_time == "TBA"
      @attrs.merge!(@week_schedule_hash) unless @week_schedule_hash.nil?
      @attrs[:professor] = Scraper.parse_professor(line)

    when Scraper.includes_additional_classtimes?(line) # Line 2 if it contains classtimes info.
      @week_schedule_hash = nil
      @week_schedule_hash = Scraper.parse_additional_classtimes(line)
      @week_schedule_hash.reject!{ |k,v| v.nil? } #reject any nil values to avoid overwriting
      @attrs.merge!(@week_schedule_hash)

    when Scraper.parse_llm_only?(line)
      @attrs[:llm_only] = true

    when Scraper.parse_jd_only?(line)
      @attrs[:jd_only] = true

    when Scraper.parse_alt_schedule?(line)
      @attrs[:alt_schedule] = true

    else
      @attrs[:additional_info] = line.to_s #uncategorized.
    end
    return @attrs
  end







  # GWU Scraper
  def self.business_hours?
    (Time.now.hour > 8 && Time.now.hour < 19) ? true : false
  end

  # Takes attributes_list of strings designating attributes of the course object
  # to match against the array_of_courses. Avoids all-or-nothing matches.
  def self.deep_match_course_attributes(attributes_list, course, array_of_courses)
    return false if course.class != Course # Check that the item is a course
    return false if attributes_list.class != Array
    return false if array_of_courses.class != Array

    array_of_courses.each do |course_|
      @mismatch_found = false

      attributes_list.each do |attrib|
        if ( course_.send(attrib) != course.send(attrib) )
          @mismatch_found = true
          break
        end
      end
      return true unless @mismatch_found
    end
    @mismatch_found ? false : true
  end

  # Slices the text into each line.
  def self.slice_into_lines(text)
    text.scan(/\n.+/).map{ |s| s}
  end

  def self.line_includes_crn?(line)
    line =~ /\d{5}/i ? true : false
  end

  def self.parse_crn(line)
    line.scan(/\d{5}/)[0]
  end

  def self.parse_gwid(line)
    line.scan(/\d\s+(\d{4})\s/).flatten[0]
  end

  def self.parse_section(line)
    line.scan(/\d\s+(\d{2})\s/).flatten[0]
  end

  def self.parse_course_name(line)
    name = line.scan(/\d{2}\s+([A-Za-z\/\-]+[^\d]+)/)
    name = name.flatten[0].lstrip.rstrip unless name.flatten.empty?
    return name
  end

  def self.parse_hours(line)
    hours_chunk = line.scan(/(\d\.\d\s+:?(OR)?:?(TO)?(:?(\s+\d\.\d\s+)?))/).flatten[0]
    return "variable" if hours_chunk.nil?
    hours_chunk = hours_chunk.rstrip
    return "variable" if hours_chunk.include?("TO")
    return "variable" if hours_chunk.include?("OR")
    return hours_chunk.slice(0,1)
  end

  def self.parse_days(line)
    line.scan(/\s([UMTWRFS]+\s?[UMTWRFS]?|TBA)\s/).flatten[0].sub(' ', '')
  end

  def self.parse_times(line)
    time_chunk = line.scan(/\s(\d{4}\s-\s\d{4}\s?(am|pm)|TBA)\s/).flatten[0]
    return "TBA" if time_chunk == "TBA" # This is problematic.

    start_time = time_chunk.scan(/\d{4}/)[0].to_i
    end_time = time_chunk.scan(/\d{4}/)[1].to_i

    if time_chunk.include?("pm")
      converted_times = Scraper.convert_times([start_time, end_time], "pm")
      start_time = converted_times[0]
      end_time = converted_times[1]
    end
    return [start_time, end_time]
  end

  def self.convert_times(times_array, am_pm)
    start_time = times_array[0].to_i
    end_time = times_array[1].to_i
    if am_pm == "pm"
      start_time = start_time + 1200 if ( (start_time < end_time) && (start_time < 1200) )
      end_time = end_time + 1200
    end
    return [start_time.to_s, end_time.to_s]
  end

  # Returns a hash of the times.
  def self.assign_times_to_days(days_string, times_array)
    return if days_string == "TBA"
    return unless days_string.present?
    times_array[0] = times_array[0].to_i unless times_array[0].class == Fixnum
    times_array[1] = times_array[1].to_i unless times_array[1].class == Fixnum

    # Zero them all out.
    @day1_start = @day2_start = @day3_start = @day4_start = @day5_start = @day6_start = @day7_start = nil
    @day1_end = @day2_end = @day3_end = @day4_end = @day5_end = @day6_end = @day7_end = nil

    days_string.scan(/\w/).each do |day|
      if day == 'U'
        @day1_start = times_array[0]
        @day1_end = times_array[1]
      end
      if day == 'M'
        @day2_start = times_array[0]
        @day2_end = times_array[1]
      end
      if day == 'T'
        @day3_start = times_array[0]
        @day3_end = times_array[1]
      end
      if day == 'W'
        @day4_start = times_array[0]
        @day4_end = times_array[1]
      end
      if day == 'R'
        @day5_start = times_array[0]
        @day5_end = times_array[1]
      end
      if day == 'F'
        @day6_start = times_array[0]
        @day6_end = times_array[1]
      end
      if day == 'S'
        @day7_start = times_array[0]
        @day7_end = times_array[1]
      end
    end

    return {
      "day1_start": @day1_start,
      "day1_end": @day1_end,
      "day2_start": @day2_start,
      "day2_end": @day2_end,
      "day3_start": @day3_start,
      "day3_end": @day3_end,
      "day4_start": @day4_start,
      "day4_end": @day4_end,
      "day5_start": @day5_start,
      "day5_end": @day5_end,
      "day6_start": @day6_start,
      "day6_end": @day6_end,
      "day7_start": @day7_start,
      "day7_end": @day7_end,
    }
  end

  def self.parse_professor(line)
    matches = line.scan(/\s?(am|pm|TBA)\s+?(.+)/i).flatten
    # Split each array element into its words also.
    @potential_profs = []
    matches.each do |match|
      @potential_profs << match.lstrip.rstrip.gsub(/\s/,' ').split(' ')
    end
    @potential_profs.flatten!

    return "STAFF" if @potential_profs.include?("STAFF")
    @potential_profs = @potential_profs - ['am', 'pm', "STAFF", "TBA"] # remove things that are obviously not names
    return @potential_profs.first
  end

  # returns a what?
  def self.parse_additional_classtimes(line)
    elements = line.scan(/([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z\/-]+/).flatten
    days = elements[0]
    start_time = elements[1]
    end_time = elements[2]
    am_pm = elements[3]

    converted_times = Scraper.convert_times([start_time, end_time], am_pm)
    Scraper.assign_times_to_days(days, converted_times)
  end

  # Merges 2 into 1. 2 will overwrite 1 if 2 is defined.
  def self.combine_attribute_hashes(attribute_hash_1, attribute_hash_2)
    # Get rid of any in 2 that are nil
    attribute_hash_2.reject!{ |k,v| v.blank? }
    attribute_hash_1.merge(attribute_hash_2)
  end

  def self.includes_additional_classtimes?(line)
    /([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z\/-]+/.match(line) ? true : false
  end

  def self.parse_llm_only?(line)
    return true if /LL.M.?s\s+ONLY/i.match(line)
    /OPEN\s+ONLY\s+TO\s+LLMs/i.match(line) ? true : false
  end

  def self.parse_jd_only?(line)
    /\(J.D.s only\)/.match(line) ? true : false
  end

  def self.parse_course_name_2(line)
    /(\(.+[^J.D.s only]\))/.match(line)
    # need to lstrip and rstrip these I think
  end

  def self.parse_alt_schedule?(line)
    /(alternat|modified)/.match(line) ? true : false
  end

  def self.parse_additional_info(line)

  end

  # Spits out the chunk corresponding to the given CRN that's fed
  # into parse_course_chunk.
  def self.inspect_crn_chunk(source, crn)
    url = source.url
    crn = crn.to_s # Might be unnecessary bc of Ruby magic
    src = Yomu.new url
    chunks = Scraper.split_by_crns(src.text)
    chunks.each do |chunk|
      return chunk if chunk.include?(crn)
    end
  end

  def self.scrape_gwu_exam_pdf!(scrape_url_object)
    src = Yomu.new scrape_url_object.url
    new_text = src.text

    @school = School.find_by(name: "GWU")
    Scraper.scrape_gwu_exam_dates_times(scrape_url_object)

    @semester = scrape_url_object.semester
    @final_date_options = @school.final_date_options
    @final_time_options = @school.final_time_options

    # process:
    # 1. capture everything after and including "EXAMINATION SCHEDULE" in new_text
    exam_page_text = new_text.match(/(EXAMINATION SCHEDULE.+)/m).to_s

    # figure out which courses have finals on which day based on which ones are between date_options
    @final_date_options.each_with_index do |start_day, index|
      @start = @final_date_options[index]

      if @final_time_options.size - 1 == index.to_i #if it's the last day, the end will just be the end of the document.
        @end = ''
      else
        @end = @final_date_options[index+1]
      end
      @days_courses = exam_page_text.match(/#{@start}(.+)#{@end}/m)[1]

      @days_courses.scan(/((\d{4})-(\d{2}))/) { |gwid|
        # find the course with the gwid, check it's final date and if it's different than this guess and manual_lock is false, change it.
        @gwid = $2
        @section = $3

        #get the course's info and update it if the scraper has new info
        if course = Course.find_by(gwid: @gwid, section: @section, semester_id: @semester.id)
          course.final_date != @start ? course.final_date = @start : course.final_date = course.final_date
          course.save! unless course.manual_lock == true
        end

      }
    end
  end

  def self.scrape_gwu_exam_dates_times(scrape_url_object)
    src = Yomu.new scrape_url_object.url
    new_text = src.text

    @school = School.find_by(name: "GWU")
    @semester = scrape_url_object.semester

    # process:
    # 1. capture everything after and including "EXAMINATION SCHEDULE" in new_text
    exam_page_text = new_text.match(/(EXAMINATION SCHEDULE.+)/m).to_s

    #find times of the form '9:30 A.M. 2:00 P.M. 6:30 P.M.' which are the timeslots.
    @final_time_options = []
    exam_page_text.scan(/(\d:\d{2}\s\D.\D.)\s(\d:\d{2}\s\D.\D.)\s(\d:\d{2}\s\D.\D.)/) { |m|
      @final_time_options << $1 << $2 << $3
    }

    @final_date_options = []
    exam_page_text.scan(/(\d\d?\/\d\d?)/) { |m|
      @final_date_options << m
    }
    @final_date_options.flatten!

    @school.final_time_options = @final_time_options
    @school.final_date_options = @final_date_options
    @school.save!
  end








end

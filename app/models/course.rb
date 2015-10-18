class Course < ActiveRecord::Base
  before_save :add_to_listbooks, :update_popularity, :coerce_times_to_string

  #relationship to schedules
  has_many :courseschedules
  has_many :schedules, through: :courseschedules

  # Only one semester per instance of these classes.
  belongs_to :semester
  # belongs_to :school # Someday. Currently course.school is a string :(

	has_many :subscriptions
	has_many :users, through: :subscriptions

  # Connecting Course to Listbooks
  has_many :coursebooks
  has_many :listbooks, :through => :coursebooks

  # The primary scrape routine.
  def self.scrape_gwu!
    @school = School.find_by(name: "GWU")
    @semester = Semester.find_by(name: "spring2016")
    source = Scrapeurl.where(name: "crn", school:@school, semester:@semester).first
    if source.source_changed?
      scraped_courses = Course.scrape_gwu_crn_pdf(source)
      Course.save_courses_to_db(scraped_courses)
      source.update_digest!
      source.update_last_scraped!
      @school.crn_last_scraped = Time.now
    end
    source.last_checked = Time.now
    source.save!

    @school.crn_last_checked = Time.now

    src = Scrapeurl.where(name: "exam", school:@school, semester:@semester).first
    if src.source_changed?
      Course.scrape_gwu_exam_pdf!(src)
      src.update_digest!
      src.update_last_scraped!
      @school.exam_last_scraped = Time.now
    end
    src.last_checked = Time.now
    src.save!

    @school.exam_last_checked = Time.now
    @school.save!

  end

  def next
    Course.where("id > ?", id).first.nil? ? Course.first : Course.where("id > ?", id).first
  end

  def previous
    Course.where("id < ?", id).last.nil? ? Course.last : Course.where("id < ?", id).last
  end

  def self.popular_courses
    Course.all.order(schedule_count: :desc)
  end

  def update_popularity
    self.schedule_count = self.schedules.count
  end

  def coerce_times_to_string
    attrs = [
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
      "day7_end"
    ]

    ## Fill this out later


  end

  # This needs to be modified to also subtract a course-book relation to handle cases when a book should NOT
  # be associated with a course
  def add_to_listbooks
    self.isbn.each do |isbn|
      book = Listbook.find_or_create_by(isbn: isbn)
      self.listbooks << book unless self.listbooks.include? book
      book.save!
    end
    self.pinned_isbn.each do |isbn|
      book = Listbook.find_or_create_by(isbn: isbn)
      self.listbooks << book unless self.listbooks.include? book
      book.save!
    end

    self.listbooks.uniq!
  end

  # GWU Scraper
  def self.business_hours?
    (Time.now.hour > 8 && Time.now.hour < 19) ? true : false
  end

  # Custom test method - tests to see if the self course is found exactly in the
  # array passed to it, but only for the course model attributes that matter
  # at creation to decide whether the scraper was correct. Ignores things like
  # the id and popularity metrics.
  # To use this in writing tests, define the course you want to find in the scraped
  # result, then test like so:
  # defined_course.is_found_exactly_in?(array_from_scrape_method)
  def is_found_exactly_in?(array_of_courses)
    # Define the list of attributes to match. This list must be updated regularly.
    key_attributes = [
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
    return Course.deep_match_course_attributes(key_attributes, self, array_of_courses)
  end

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
    return 0 if hours_chunk.nil?
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
      converted_times = Course.convert_times([start_time, end_time], "pm")
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

    converted_times = Course.convert_times([start_time, end_time], am_pm)
    Course.assign_times_to_days(days, converted_times)
  end

  # Merges 2 into 1. 2 will overwrite 1 if 2 is defined.
  def self.combine_attribute_hashes(attribute_hash_1, attribute_hash_2)
    # Get rid of any in 2 that are nil
    attribute_hash_2.reject!{ |k,v| v.blank? }
    attribute_hash_1.merge(attribute_hash_2)
  end

  # This allows two incomplete @course objects' attributes to be merged.
  def safe_merge_course!(new_course)
    @new_attrs = new_course.attributes.reject { |k, v| v.nil? }
    @new_attrs.reject! { |k, v| v.blank? }
    self.attributes = @new_attrs
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


  # Given an object from model Scrapeurls, this will go through it line-by-line and
  # return an array of model Course objects. This method does not save the objects
  # to the database.
  def self.scrape_gwu_crn_pdf(scrape_url_object)
    src = Yomu.new scrape_url_object.url
    # "https://schedulegw.com/gwu_test_crn_spring2015.pdf"
    @school = scrape_url_object.school.name
    @semester = scrape_url_object.semester

    course_array = Course.split_by_crns(src.text)

    scraped_courses = []
    course_array.each do |course_chunk|
      @course = nil
      @course = Course.parse_course_chunk(course_chunk)
      @course.semester_id = @semester.id
      @course.school = @school
      scraped_courses << @course
    end

    scraped_courses.reject! { |course| course.crn.nil? }

    return scraped_courses
  end

  def self.parse_course_chunk(course_chunk)
    course_lines = course_chunk.split(/\n+/)
    @attributes = {}
    course_lines.each do |course_line|
      next if course_line.blank?
      next if course_line.empty?
      @attributes.merge!(Course.gwu_parse_crn_line(course_line))
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
      course = Course.find_or_initialize_by(crn: c.crn, semester_id: c.semester_id)
      course.assign_attributes(c.attributes.reject! { |k, v| v.nil? } )
      course.save! unless course.manual_lock == true
    end
  end

  # Returns a Course object with the attributes added as found in each line.
  # If the line is the start of a new course, it starts a new Course object.
  # course_obj is the in-progress Course object (this method resets new Course obj if appropriate)
  def self.gwu_parse_crn_line(line)
    @attrs = {}
    @class_time = nil
    @week_schedule_hash = nil
    case
    when Course.line_includes_crn?(line) # First line of a course listing.
      @attrs[:crn] = Course.parse_crn(line)
      @attrs[:gwid] = Course.parse_gwid(line)
      @attrs[:section] = Course.parse_section(line)
      @attrs[:course_name] = Course.parse_course_name(line)
      @attrs[:hours] = Course.parse_hours(line)
      @attrs[:days] = Course.parse_days(line)
      @class_time = Course.parse_times(line) # Type array returned, or string "TBA"
      @week_schedule_hash = Course.assign_times_to_days(@attrs[:days], @class_time) unless @class_time == "TBA"
      @attrs.merge!(@week_schedule_hash) unless @week_schedule_hash.nil?
      @attrs[:professor] = Course.parse_professor(line)

    when Course.includes_additional_classtimes?(line) # Line 2 if it contains classtimes info.
      @week_schedule_hash = nil
      @week_schedule_hash = Course.parse_additional_classtimes(line)
      @week_schedule_hash.reject!{ |k,v| v.nil? } #reject any nil values to avoid overwriting
      @attrs.merge!(@week_schedule_hash)

    when Course.parse_llm_only?(line)
      @attrs[:llm_only] = true

    when Course.parse_jd_only?(line)
      @attrs[:jd_only] = true

    when Course.parse_alt_schedule?(line)
      @attrs[:alt_schedule] = true

    else
      @attrs[:additional_info] = line.to_s #uncategorized.
    end
    return @attrs
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

  def self.scrape_gwu_exam_pdf!(scrape_url_object)
    src = Yomu.new scrape_url_object.url
    new_text = src.text

    @school = School.find_by(name: "GWU")
    Course.scrape_gwu_exam_dates_times(scrape_url_object)

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


  def self.get_books(url)
    yomu = Yomu.new url
    text = yomu.text

    @school = School.find_by(name: "GWU") # Make this dynamic later.

    # Check to see if the booklist changed.
    new_digest = Digest::MD5.hexdigest text
    old_digest = @school.booklist_scrape_digest

    @school.booklist_last_checked = Time.now

    if new_digest != old_digest
      @school.booklist_scrape_digest = new_digest
      @school.booklist_last_scraped = Time.now
    end

    @school.save!

    final_text = text.gsub(/\n+/, " ")
    course_array = final_text.split(/\s(?=6\d{3}-\w{2,3})/)

    course_array.each do |course|
      gwid_chunk = course.match(/(6\d{3}-\w{2,3})/)
      gwid_chunk = gwid_chunk.to_s.slice(/((?:\w+-*)+)/)

      long_gwid = gwid_chunk if gwid_chunk != nil && gwid_chunk[5] != "A"
      next if long_gwid.nil? # Skip if there's no course for this chunk.

      gwid = long_gwid.scan(/(\d{4})-(\d{2})/)[0][0]
      section = long_gwid.scan(/(\d{4})-(\d{2})/)[0][1]
      current_class = Course.find_or_create_by(:gwid => gwid, :section => section)

      # Get the current isbns to compare to later to see if there's anything new.
      current_isbn = current_class.isbn

      isbn_array = course.scan(/(?<=ISBN-13):*\s*((?:\d+-*)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end
      isbn_array = course.scan(/(?<=ISBN[#:\s])\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end
      isbn_array = course.scan(/(?<=ISBN#:)\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end
      isbn_array = course.scan(/(?<=ISBN\sNumber:)\s*((?:\d+-?)+)/)
      if isbn_array != nil
        isbn_array.map! {|x| x.to_s.slice(/((?:\d+-*)+)/).gsub("-", "")}
        isbn_array.map! {|x| x[0] != "9" ? "978" + x : x}

        isbn_array.each do |book|
          current_class.isbn.include?(book) ? (next) : (current_class.isbn << book)
        end
      end

      # Remove the ISBNs that we've already flagged as wrong.
      current_class.isbn = current_class.isbn - current_class.wrong_isbn.map {|i| i.to_s }

      current_class.isbn = (current_class.isbn + current_class.pinned_isbn ).uniq

      # If the booklist is locked, note a conflict if a change is attempted.

      current_class.update_attribute('booklist_lock_conflict', true) if ( current_class.isbn.sort != current_isbn.sort && current_class.booklist_locked )

      # Actually save the course unless its a locked record
      current_class.save! unless current_class.booklist_locked

    end
    # Update the coursebooks <--> listbooks
    Course.find_each do |course|
      course.add_to_listbooks unless course.isbn.empty?
    end
  end

end

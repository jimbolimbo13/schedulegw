class Course < ActiveRecord::Base
  before_save :add_to_listbooks, :update_popularity

  #relationship to schedules
  has_many :courseschedules
  has_many :schedules, through: :courseschedules

  #possibly:
  belongs_to :schools

  # Only one semester per instance of these classes.
  belongs_to :semester

	has_many :subscriptions
	has_many :users, through: :subscriptions

  # Connecting Course to Listbooks
  has_many :coursebooks
  has_many :listbooks, :through => :coursebooks

	def self.scrape
    #load the scrapers here.
		load Dir.pwd + '/GWU_scrape.rb'
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
    line.scan(/\d{2}\s+([A-Za-z\/\-]+[^\d]+)/).flatten[0].rstrip
  end

  def self.parse_hours(line)
    hours_chunk = line.scan(/(\d\.\d\s+:?(OR)?:?(TO)?(:?(\s+\d\.\d\s+)?))/).flatten[0].rstrip
    return "variable" if hours_chunk.include?("TO")
    return "variable" if hours_chunk.include?("OR")
    return hours_chunk.slice(0,1)
  end

  def self.parse_days(line)
    line.scan(/\s([UMTWRFS]+\s?[UMTWRFS]?|TBA)\s/).flatten[0].sub(' ', '')
  end

  def self.parse_times(line)
    time_chunk = line.scan(/\s(\d{4}\s-\s\d{4}\s?(am|pm)|TBA)\s/).flatten[0]
    return "TBA" if time_chunk == "TBA"

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
    start_time = times_array[0]
    end_time = times_array[1]
    if am_pm == "pm"
      start_time = start_time + 1200 if ( (start_time < end_time) && (start_time < 1200) )
      end_time = end_time + 1200
    end
    return [start_time, end_time]
  end

  def self.assign_times_to_days(days_string, times_array)
    return if days_string == "TBA"
    days_string.scan(/(\w)/) { |s|
      case $1
      when 'U'
        @day1_start = times_array[0]
        @day1_end = times_array[1]
      when 'M'
        @day2_start = times_array[0]
        @day2_end = times_array[1]
      when 'T'
        @day3_start = times_array[0]
        @day3_end = times_array[1]
      when 'W'
        @day4_start = times_array[0]
        @day4_end = times_array[1]
      when 'R'
        @day5_start = times_array[0]
        @day5_end = times_array[1]
      when 'F'
        @day6_start = times_array[0]
        @day6_end = times_array[1]
      when 'S'
        @day7_start = times_array[0]
        @day7_end = times_array[1]
      end
    }

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

  def self.parse_additional_classtimes(line)
    elements = line.scan(/([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z\/-]+/).flatten
    days = elements[0]
    start_time = elements[1]
    end_time = elements[2]
    am_pm = elements[3]

    converted_times = Course.convert_times([start_time, end_time], am_pm)
    Course.assign_times_to_days(days, converted_times)
  end

  def self.includes_additional_classtimes?(line)
    /([MTWRF]+)\s+(\d{4})\s+.\s+(\d{4})(\D\D)\s+[A-Za-z\/-]+/.match(line) ? true : false
  end

  def self.parse_llm_only?(line)
    /LL.Ms\s+ONLY/.match(line) ? true : false
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

  def self.scrape_gwu!
    source = Yomu.new Scrapeurl.find_by(name: "crn").url
    Course.scrape_gwu_crn(source.text)
  end



  def self.scrape_gwu_crn(text)
    new_text = text
    @response = []

    sliced_text = Course.slice_into_lines(new_text)

    # if starts with CRN
    sliced_text.each_with_index do |i, line|

      if Course.line_includes_crn?(line)
        # Clear anything that might be residual

        @crn = Course.parse_crn(line)
        @gwid = Course.parse_gwid(line)
        @section = Course.parse_section(line)
        @course_name = Course.parse_course_name(line)
        @hours = Course.parse_hours(line)
        @days = Course.parse_days(line)
        @class_time = Course.parse_times(line)
        @week_schedule = Course.assign_times_to_days(@days, @class_time) # type hash returned
        @professor = Course.parse_professor(line)
      else
        # The line isn't one with a CRN in it. Might be junk, might be part of the previous line's info.
        if Course.includes_additional_classtimes?(line)
          @week_schedule_2 = Course.parse_additional_classtimes(line)
        end
        @llm_only = true if Course.parse_llm_only?(line)
        @jd_only = true if Course.parse_jd_only?(line)
        @alt_schedule = true if Course.parse_alt_schedule?(line)
      end

    end


        ## match the professor to Professorlist. Lastname
        $prof_id = Professorlist.find_by(last_name: $professor) ? Professorlist.find_by(last_name: $professor).prof_id : 0

        # Create the object to return.

        course = Course.new
          course.crn = $crn
          course.course_name = $course_name
          course.course_name_2 = $course_name_2
          course.gwid = $gwid
          course.section = $section
          course.hours = $hours

          course.day1_start = $day1_start
          course.day1_end = $day1_end

          course.day2_start = $day2_start
          course.day2_end = $day2_end

          course.day3_start = $day3_start
          course.day3_end = $day3_end

          course.day4_start = $day4_start
          course.day4_end = $day4_end

          course.day5_start = $day5_start
          course.day5_end = $day5_end

          course.day6_start = $day6_start
          course.day6_end = $day6_end

          course.day7_start = $day7_start
          course.day7_end = $day7_end

          course.llm_only = $llm_only
          course.jd_only = $jd_only
          course.alt_schedule = $alt_schedule
          course.additional_info = $additional_info
          course.professor = $professor
          course.prof_id = $prof_id
          course.school = School.find_by(name: "GWU").name


          @response.each do |included_course|
            if included_course.crn == $crn
              @already_included = true
              break
            end
          end

          # Add this course to the return object
          @response << course unless @already_included

      }

      # Return an array of every class in this crn pdf scrape.
      return @response

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

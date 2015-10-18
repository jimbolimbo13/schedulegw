require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert courses(:evidence).valid?, "Evidence wasnt a valid course"
    assert courses(:pre).valid?, "PRE wasnt a valid course"
  end

  # Make sure it's between 8am and 7pm
  test "self.business_hours?" do
    @response = Course.business_hours?
    if (Time.now.hour > 8 && Time.now.hour < 19)
      assert @response
    else
      assert_not @response
    end
  end

  test "deep_match_course_attributes" do
    @attributes_list = ["crn", "gwid", "section"]
    @course_list = Course.first(100).to_a
    @course = courses(:contractsII)

    assert Course.deep_match_course_attributes(@attributes_list, @course, @course_list), "Did not find a course that should be in the returned set."
  end

  test "deep_match_course_attributes contra" do
    @attributes_list = ["crn", "gwid", "section"]
    @course_list = Course.first(100).to_a
    @course = courses(:contractsII)
    @course.crn = '1111111111111' # This is not the correct value, so this should fail to find a match

    assert_not Course.deep_match_course_attributes(@attributes_list, @course, @course_list)
  end

  test "line_includes_crn?" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.line_includes_crn?(line)
  end

  test "parse_crn" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_crn(line) == "40948"
  end

  test "parse_gwid" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_gwid(line) == "6203"
  end

  test "parse_section" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_section(line) == "11"
  end

  test "parse course_name" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_course_name(line) == "Contracts II"
  end

  test "parse hours" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    assert Course.parse_hours(line) == "3"
  end

  test "parse hours [case: 'or']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Course.parse_hours(line) == "variable"
  end

  test "parse hours [case: 'to']" do
    line = "\n 41010   6697    25  Graduate Clinical Studies        1.0 TO 4.0  TBA         TBA                          STAFF"
    assert Course.parse_hours(line) == "variable"
  end

  test "parse days" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_days(line) == "MTW"
  end

  test "parse days [case: 'TBA']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Course.parse_days(line) == "TBA"
  end

  test "parse days [case: 'T W' (space)]" do
    line = "\n 40951   6203    21  Contracts II                     3.0         T W         0600 - 0800pm                Wilmarth"
    assert Course.parse_days(line) == "TW"
  end

  test "parse times [case: both start and end are pm]" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_times(line) == ["1340", "1435"]
  end

  test "parse times [case: both start and end are am]" do
    line =  "\n 40958   6214    14  Constitutional Law I             3.0         MWR         0850 - 0945am                Smith"
    assert Course.parse_times(line) == [850, 945]
  end

  test "parse times [case: 'TBA']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Course.parse_times(line) == "TBA"
  end

  test "parse professor" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_professor(line) == "Selmi"
  end

  test "parse professor 2" do
    line = "\n 43218   6254    10  Corporate Finance                2.0         R           0140 - 0340pm                Turilli"
    assert Course.parse_professor(line) == "Turilli"
  end

  test "parse professor [case: 'STAFF']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Course.parse_professor(line) == "STAFF"
  end

  test "parse additional class times (line 2)" do
    line = "\n                                                                  F           1100 - 1155am                Fairfax"
    assert Course.parse_additional_classtimes(line)[:day6_start] == "1100"
    assert Course.parse_additional_classtimes(line)[:day6_end] == "1155"
  end

  # Makes sure courses with classtimes on two diff. lines get combined correctly.
  test "combine attribute hashes" do
    @week_schedule_1 = {
      "day1_start": 1200,
      "day1_end": 1300,
      "day2_start": nil,
      "day2_end": nil,
      "day3_start": nil,
      "day3_end": nil,
      "day4_start": 1100,
      "day4_end": 1200,
      "day5_start": nil,
      "day5_end": nil,
      "day6_start": nil,
      "day6_end": nil,
      "day7_start": nil,
      "day7_end": nil,
    }

    @week_schedule_2 = {
      "day1_start": nil,
      "day1_end": nil,
      "day2_start": nil,
      "day2_end": nil,
      "day3_start": nil,
      "day3_end": nil,
      "day4_start": nil,
      "day4_end": nil,
      "day5_start": nil,
      "day5_end": nil,
      "day6_start": 1345,
      "day6_end": 1435,
      "day7_start": "",
      "day7_end": "",
    }

    @expected_schedule = {
      "day1_start": 1200,
      "day1_end": 1300,
      "day2_start": nil,
      "day2_end": nil,
      "day3_start": nil,
      "day3_end": nil,
      "day4_start": 1100,
      "day4_end": 1200,
      "day5_start": nil,
      "day5_end": nil,
      "day6_start": 1345,
      "day6_end": 1435,
      "day7_start": nil,
      "day7_end": nil,
    }

    @combined_schedule = Course.combine_attribute_hashes(@week_schedule_1, @week_schedule_2)
    assert @combined_schedule = @expected_schedule
  end

  # Builds on the combine_attribute_hashes method to allow us to merge two
  # incomplete @course objects together
  test "safe_merge_course! " do
    @course = Course.new(
      course_name: "First Course",
      crn: "11111",
      day1_start: "1435",
      day1_end: "1540",
      day2_start: "900",
      day2_end: "1000",
      day3_start: "100",
      day3_end: "200",
      day4_start: "",
      day4_end: "",
      day5_start: nil,
      day5_end: nil,
      day6_start: "1400",
      day6_end: "1550"
    )
    @new_course = Course.new(
      course_name: "New Course Name",
      day2_start: nil,
      day2_end: nil,
      day3_start: "",
      day3_end: "",
      day4_start: "1200",
      day4_end: "1400",
      day5_start: "600",
      day5_end: "750",
      day6_start: nil,
      day6_end: nil
    )

    @expected_course = Course.new(
      course_name: "New Course Name", # New data overwrites old data
      crn: "11111", # value should remain.
      day1_start: "1435", # @course stays the same
      day1_end: "1540", # @course stays the same
      day2_start: "900",
      day2_end: "1000",
      day3_start: "100", #blank should not overwrite a value
      day3_end: "200", #blank should not overwrite a value
      day4_start: "1200", #blank should get overwritten by new value
      day4_end: "1400", #blank should get overwritten by new value
      day5_start: "600",
      day5_end: "750",
      day6_start: "1400",
      day6_end: "1550"
    )

    @course.safe_merge_course!(@new_course)

    assert @course.course_name = @expected_course.course_name, "course_name safe merge failed"
    assert @course.crn = @expected_course.crn, "CRN safe merge failed"
    assert @course.day1_start = @expected_course.day1_start, "day1_start safe merge failed"
    assert @course.day1_end = @expected_course.day1_end, "day1_end safe merge failed "
    assert @course.day2_start = @expected_course.day2_start, "day2_start safe merge failed "
    assert @course.day2_end = @expected_course.day2_end, "day2_end safe merge failed"
    assert @course.day3_start = @expected_course.day3_start, "day3_start safe merge failed"
    assert @course.day3_end = @expected_course.day3_end, "day3-end safe merge failed"
    assert @course.day4_start = @expected_course.day4_start, "day4 start safe merge failed"
    assert @course.day4_end = @expected_course.day4_end, "day4 end safe merge failed"
    assert @course.day5_start = @expected_course.day5_start, "day5start safe merge failed"
    assert @course.day5_end = @expected_course.day5_end, "day5 end safe merge failed"
    assert @course.day6_start = @expected_course.day6_start, "day6start safe merge failed"
    assert @course.day6_end = @expected_course.day6_end, "day6 end safe merge failed"

    assert @course = @expected_course, "total comparison safe merge failed "
  end

  # This just runs every single line through the parser to find errors.
  test "[gwu_parse_crn_line] smoke test for runtime errors" do
    # spring 2015
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    lines.each do |line|
      Course.gwu_parse_crn_line(line)
    end
    # fall 2015
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_fall2015.pdf"
    lines = Course.slice_into_lines(source.text)
    lines.each do |line|
      Course.gwu_parse_crn_line(line)
    end
    # spring 2016
    source = Yomu.new "http://www.law.gwu.edu/Students/Records/Spring2016/Documents/Spring%202016%20Schedule%20with%20CRNs.pdf"
    lines = Course.slice_into_lines(source.text)
    lines.each do |line|
      Course.gwu_parse_crn_line(line)
    end
  end

  test "[gwu_parse_crn_line] crn-containing line, standard" do
    @line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    @parsed_course = Course.gwu_parse_crn_line(@line)
    assert @parsed_course[:crn] = '40948'
    assert @parsed_course[:gwid] = '6203'
    assert @parsed_course[:section] = '11'
    assert @parsed_course[:course_name] = "Contracts II"
    assert @parsed_course[:hours] = "3"
    assert @parsed_course[:days] = "MTW"
    assert @parsed_course[:day2_start] = 1340
    assert @parsed_course[:day2_end] = 1435
    assert @parsed_course[:day3_start] = 1340
    assert @parsed_course[:day3_end] = 1435
    assert @parsed_course[:day4_start] = 1340
    assert @parsed_course[:day4_end] = 1435
    assert @parsed_course[:professor] = "Selmi"
  end

  test "[gwu_parse_crn_line] - additional classtimes line" do
    @line = "\n                                                                  F           1100 - 1155am                Fairfax"
    @parsed_course = Course.gwu_parse_crn_line(@line)
    assert @parsed_course[:day6_start] = 1100
    assert @parsed_course[:day6_end] = 1155
  end

  test "[gwu_parse_crn_line] - llm only v1" do
    @line = "\n                            LL.M.s Only"
    @parsed_course = Course.gwu_parse_crn_line(@line)
    assert @parsed_course[:llm_only] = true
  end

  test "[gwu_parse_crn_line] - llm only v2" do
    @line = "\n                            OPEN ONLY TO LLMs"
    @parsed_course = Course.gwu_parse_crn_line(@line)
    assert @parsed_course[:llm_only] = true
  end

  test "[gwu_parse_crn_line] - jd only" do
    @line = "\n                       (J.D.s only)                                                                        Rainey   Gardner"
    @parsed_course = Course.gwu_parse_crn_line(@line)
    assert @parsed_course[:jd_only] = true
  end

  test "[gwu_parse_crn_line] - alternate schedule" do
    @line = "\n                           Course meets Tuesdays and alternate Wednesdays"
    @parsed_course = Course.gwu_parse_crn_line(@line)
    assert @parsed_course[:alt_schedule] = true
  end

  test "self.scrape_gwu_crn_pdf total course count (coarse)" do
    ob = scrapeurls(:gwu_test_crn_spring2015)
    scraped_courses = Course.scrape_gwu_crn_pdf(ob)
    # Actual count is 307
    assert scraped_courses.count <= 310, "Found #{scraped_courses.count} instead of fewer than 310"
    assert scraped_courses.count >= 300, "Found #{scraped_courses.count} instead of more than 300"
  end

  test "self.scrape_gwu_crn_pdf has crns of courses near page breaks" do
    edge_crns = [
      "44815",
      "41173",
      "41172",
      "43300",
      "43299",
      "43298",
      "43300",
      "40999",
      "41170",
      "43537",
      "45890",
      "44795",
      "41923",
      "45773",
      "44786",
      "44776",
      "44873",
      "43218",
      "43217",
      "40948",
      "41807"
    ]

    ob = scrapeurls(:gwu_test_crn_spring2015)
    scraped_courses = Course.scrape_gwu_crn_pdf(ob)
    scraped_crns = scraped_courses.map {|c| c.crn }
    edge_crns.each do |ec|
      assert scraped_crns.include?(ec), "List of scraped courses did not include CRN #{ec}"
    end

  end

  test "self.scrape_gwu_crn_pdf first course spring2015" do
    ob = scrapeurls(:gwu_test_crn_spring2015)
    assert ob.semester = semesters(:spring2015)
    scraped_courses = Course.scrape_gwu_crn_pdf(ob)
    scraped_courses.each do |c|
      if c.crn == "40948"
        assert c.course_name = "Contracts II"
        assert c.days = "MTW"
        assert c.day1_start = ""
        assert c.day1_end = ""
        assert c.day2_start = "1340"
        assert c.day2_end = "1435"
        assert c.day3_start = "1340"
        assert c.day3_end = "1435"
        assert c.day4_start = "1340"
        assert c.day4_end = "1435"
        assert c.professor = "Selmi"
      end
    end
  end

  test "self.scrape_gwu_crn_pdf first course spring2016" do
    ob = scrapeurls(:gwu_test_crn_spring2016)
    assert ob.semester = semesters(:spring2016)
    scraped_courses = Course.scrape_gwu_crn_pdf(ob)
    scraped_courses.each do |c|
      if c.crn == "70890"
        assert c.course_name = "Contracts II"
        assert c.day1_start = ""
        assert c.day1_end = ""
        assert c.day2_start = "1205"
        assert c.day2_end = "1300"
        assert c.day3_start = "1100"
        assert c.day3_end = "1155"
        assert c.day4_start = "955"
        assert c.day4_end = "1050"
        assert c.professor = "Selmi"
      end
      # Check the next class to make sure it's also right.
      if c.crn == "70891"
        assert c.course_name = "Contracts II"
        assert c.day1_start = ""
        assert c.day1_end = ""
        assert c.day2_start = ""
        assert c.day2_end = ""
        assert c.day3_start = ""
        assert c.day3_end = ""
        assert c.day4_start = "850"
        assert c.day4_end = "945"
        assert c.day5_start = "850"
        assert c.day5_end = "945"
        assert c.day6_start = "1100"
        assert c.day6_end = "1155"
        assert c.professor = "Swaine"
      end

    end
  end

  test "assign semester from fixtures to a new course" do
    @course = Course.new
    @course.semester = semesters(:spring2016)
    assert @course.semester.name = "spring2016"
  end

  test "assign semester from ORM to a new course" do
    @course = Course.new
    @course.semester = Semester.first
    assert @course.semester.name = Semester.first.name
  end

  test "parse course chunk" do
    ob = scrapeurls(:gwu_test_crn_spring2015)
    src = Yomu.new ob.url
    course_array = Course.split_by_crns(src.text)
    contracts = course_array[2] # Contracts II with Fairfax (2 lines)
    # "40949   6203    12  Contracts II                     3.0         WR          0850 - 0945am                Fairfax\n                                                                  F           1100 - 1155am                Fairfax\n\n "
    @course = Course.parse_course_chunk(contracts)
    assert @course.course_name = "Contracts II"
    assert @course.hours = "3"
    assert @course.crn = "40949"
    assert @course.day6_start = "1100"
    assert @course.day6_end = "1155"

  end

































end

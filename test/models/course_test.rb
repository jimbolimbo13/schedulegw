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

  test "Split pdf into lines" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines.last == "\nupdated January 7, 2015"
    assert lines.first == "\n                                                  Schedule of Classes - Spring, 2015                               PAGE 1"
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
    assert Course.parse_hours(lines) == "variable"
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
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[12].include?("T W".to_s)
    assert Course.parse_days(lines[12]) == "TW"
  end

  test "parse times [case: both start and end are pm]" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Course.parse_times(line) == ["1340", "1435"]
  end

  test "parse times [case: both start and end are am]" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[32].include?("0850 - 0945am".to_s) # Times each day
    assert Course.parse_times(lines[32]) == [850, 945]
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
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[8].include?("1100 - 1155am".to_s) # Times each day

    assert Course.parse_additional_classtimes(lines[8])[:day6_start] == "1100"
    assert Course.parse_additional_classtimes(lines[8])[:day6_end] == "1155"
  end

  # Makes sure courses with classtimes on two diff. lines get combined correctly.
  test "combine attribute hashes" do
    @course = Course.new
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
      "day7_start": nil,
      "day7_end": nil,
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
      "day6_start": nil,
      "day6_end": 1345,
      "day7_start": 1435,
      "day7_end": nil,
    }

    @combined_schedule = @course.combine_attribute_hashes(@week_schedule_1, @week_schedule_2)
    assert @combined_schedule = @expected_schedule
  end

  test "assign_hash_to_attrs" do
    @course = Course.new

    @classtimes = {
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
      "day6_end": 1345,
      "day7_start": 1435,
      "day7_end": nil,
    }

    @course.assign_hash_to_attrs(@classtimes)

    @classtimes.each { |k, v|
      assert @course.send(k) == v.to_s, "Expected #{k}(#{k.class}) to be #{v}(#{k.class}) but it was #{@course.send(k)}(#{@course.send(k).class})"
    }

  end

  test "[gwu_parse_crn_line] smoke test for runtime errors" do
    @course = Course.new
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    lines.each do |line|
      Course.gwu_parse_crn_line(line, @course)
    end
  end

  test "[gwu_parse_crn_line] crn-containing line, standard" do
    @course = Course.new
    @line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    @parsed_course = Course.gwu_parse_crn_line(@line, @course)
    assert @parsed_course.crn = '40948'
    assert @parsed_course.gwid = '6203'
    assert @parsed_course.section = '11'
    assert @parsed_course.course_name = "Contracts II"
    assert @parsed_course.hours = "3"
    assert @parsed_course.days = "MTW"
    assert @parsed_course.day2_start = 1340
    assert @parsed_course.day2_end = 1435
    assert @parsed_course.day3_start = 1340
    assert @parsed_course.day3_end = 1435
    assert @parsed_course.day4_start = 1340
    assert @parsed_course.day4_end = 1435
    assert @parsed_course.professor = "Selmi"
  end

  test "[gwu_parse_crn_line] - additional classtimes line" do
    @course = Course.new
    @line = "\n                                                                  F           1100 - 1155am                Fairfax"
    @parsed_course = Course.gwu_parse_crn_line(@line, @course)
    assert @parsed_course.day6_start = 1100
    assert @parsed_course.day6_end = 1155
  end

  test "[gwu_parse_crn_line] - llm only v1" do
    @course = Course.new
    @line = "\n                            LL.M.s Only"
    @parsed_course = Course.gwu_parse_crn_line(@line, @course)
    assert @parsed_course.llm_only
  end

  test "[gwu_parse_crn_line] - llm only v2" do
    @course = Course.new
    @line = "\n                            OPEN ONLY TO LLMs"
    @parsed_course = Course.gwu_parse_crn_line(@line, @course)
    assert @parsed_course.llm_only
  end

  test "[gwu_parse_crn_line] - jd only" do
    @course = Course.new
    @line = "\n                       (J.D.s only)                                                                        Rainey   Gardner"
    @parsed_course = Course.gwu_parse_crn_line(@line, @course)
    assert @parsed_course.jd_only
  end

  test "[gwu_parse_crn_line] - alternate schedule" do
    @course = Course.new
    @line = "\n                           Course meets Tuesdays and alternate Wednesdays"
    @parsed_course = Course.gwu_parse_crn_line(@line, @course)
    assert @parsed_course.alt_schedule
  end



























end

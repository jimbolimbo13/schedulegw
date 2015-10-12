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
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?(40948.to_s)
    assert Course.line_includes_crn?(lines[6])
  end

  test "parse_crn" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?(40948.to_s)
    assert Course.parse_crn(lines[6]) == "40948"
  end

  test "parse_gwid" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?(6203.to_s)
    assert Course.parse_gwid(lines[6]) == "6203"
  end

  test "parse_section" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?(11.to_s)
    assert Course.parse_section(lines[6]) == "11"
  end

  test "parse course_name" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?("Contracts II".to_s)
    assert Course.parse_course_name(lines[6]) == "Contracts II"
  end

  test "parse hours" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?("3.0".to_s)
    assert Course.parse_hours(lines[6]) == "3"
  end

  test "parse hours [case: 'or']" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[461].include?("1.0 OR 2.0".to_s)
    assert Course.parse_hours(lines[461]) == "variable"
  end

  test "parse hours [case: 'to']" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[463].include?("1.0 TO 4.0".to_s)
    assert Course.parse_hours(lines[463]) == "variable"
  end

  test "parse days" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?("MTW".to_s)
    assert Course.parse_days(lines[6]) == "MTW"
  end

  test "parse days [case: 'TBA']" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[461].include?("TBA".to_s)
    assert Course.parse_days(lines[461]) == "TBA"
  end

  test "parse days [case: 'T W' (space)]" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[12].include?("T W".to_s)
    assert Course.parse_days(lines[12]) == "TW"
  end

  test "parse times [case: both start and end are pm]" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?("0140 - 0235pm".to_s) # Times each day
    assert lines[6].include?("MTW".to_s) # Days of the week
    assert Course.parse_times(lines[6]) == [1340, 1435]
  end

  test "parse times [case: both start and end are am]" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[32].include?("0850 - 0945am".to_s) # Times each day
    assert Course.parse_times(lines[32]) == [850, 945]
  end

  test "parse times [case: 'TBA']" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[461].include?("TBA".to_s) # Times each day
    assert Course.parse_times(lines[461]) == "TBA"
  end

  test "parse professor" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[6].include?("Selmi".to_s) # Times each day
    assert Course.parse_professor(lines[6]) == "Selmi"
  end

  test "parse professor 2" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[60].include?("Turilli".to_s) # Times each day
    assert Course.parse_professor(lines[60]) == "Turilli"
  end

  test "parse professor [case: 'STAFF']" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[461].include?("STAFF".to_s) # Times each day
    assert Course.parse_professor(lines[461]) == "STAFF"
  end

  test "parse additional class times (line 2)" do
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Course.slice_into_lines(source.text)
    assert lines[8].include?("1100 - 1155am".to_s) # Times each day

    assert Course.parse_additional_classtimes(lines[8])[:day6_start] == "1100"
    assert Course.parse_additional_classtimes(lines[8])[:day6_end] == "1155"
  end

  





















end

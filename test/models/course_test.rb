require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert courses(:evidence).valid?, "Evidence wasnt a valid course"
    assert courses(:pre).valid?, "PRE wasnt a valid course"
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

































end

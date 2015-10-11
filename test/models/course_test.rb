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

  # Custom test method - tests to see if the self course is found exactly in the
  # array passed to it, but only for the course model attributes that matter
  # at creation to decide whether the scraper was correct. Ignores things like
  # the id and popularity metrics.
  # To use this in writing tests, define the course you want to find in the scraped
  # result, then test like so:
  # defined_course.is_found_exactly_in?(array_from_scrape_method)
  # This test makes sure the core method works.
  test "is_found_exactly_in?" do
    @course = Course.new
    @course.crn = 74141
    @course.gwid = 6880
    @course.section = 10



  end

  test "The include? method finds if a course is in the returned array of courses" do
    @course = Course.new
    @course.crn = "74141"
    @course.gwid = "6880"
    @course.section = "10"
    @course.course_name = "Disaster Law"
    @course.hours = "2"
    @course.days = nil
    @course.day1_start = nil
    @course.day1_end = nil
    @course.day2_start = "1340"
    @course.day2_end = "1540"
    @course.day3_start = nil
    @course.day3_end = nil
    @course.day4_start = nil
    @course.day4_end = nil
    @course.day5_start = nil
    @course.day5_end = nil
    @course.day6_start = nil
    @course.day6_end = nil
    @course.day7_start = nil
    @course.day7_end = nil
    @course.llm_only = true
    @course.jd_only = nil
    @course.course_name_2 = nil
    @course.alt_schedule = nil
    @course.additional_info = "Schedule of Classes - Spring, 2015                               PAGE 1"
    @course.professor = "Abbott"
    @course.prof_id = 14019
    @course.final_time = nil
    @course.final_date = nil
    @course.school = "GWU"


    text = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    text = text.text
    @scraped_array = Course.scrape_gwu_crn(text)

    assert @scraped_array.include?(@course), "Couldn't find course in the scraped array"

  end


end

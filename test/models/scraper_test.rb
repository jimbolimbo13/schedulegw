require 'test_helper'
class ScraperTest < ActiveSupport::TestCase

  # Make sure it's between 8am and 7pm
  test "self.business_hours?" do
    @response = Scraper.business_hours?
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

    assert Scraper.deep_match_course_attributes(@attributes_list, @course, @course_list), "Did not find a course that should be in the returned set."
  end

  test "deep_match_course_attributes contra" do
    @attributes_list = ["crn", "gwid", "section"]
    @course_list = Course.first(100).to_a
    @course = courses(:contractsII)
    @course.crn = '1111111111111' # This is not the correct value, so this should fail to find a match

    assert_not Scraper.deep_match_course_attributes(@attributes_list, @course, @course_list)
  end

  test "line_includes_crn?" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.line_includes_crn?(line)
  end

  test "parse_crn" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.parse_crn(line) == "40948"
  end

  test "parse_gwid" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.parse_gwid(line) == "6203"
  end

  test "parse_section" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.parse_section(line) == "11"
  end

  test "it should find sections format 25A 26B etc. " do
    line = "71841   6656    25A Independent Legal Writing        1.0 OR 2.0  TBA         TBA                          STAFF\n"
    assert Scraper.parse_section(line) == "25A"
  end

  test "parse course_name" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.parse_course_name(line) == "Contracts II"
  end

  test "parse course_name (random edge case with US in title getting confused with days)" do
    line = "77506   6594    10  History of the US Constitution   3.0         TR          0350 - 0515pm                Wilmarth\n"
    assert Scraper.parse_course_name(line) == "History of the US Constitution"
  end

  test "parse course_name - When Section includes a letter" do
    line = "77506   6594    10A  History of the US Constitution   3.0         TR          0350 - 0515pm                Wilmarth\n"
    assert Scraper.parse_course_name(line) == "History of the US Constitution"
  end

  test "parse hours" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    assert Scraper.parse_hours(line) == "3"
  end

  test "parse hours [case: 'or']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Scraper.parse_hours(line) == "variable"
  end

  test "parse hours [case: 'to']" do
    line = "\n 41010   6697    25  Graduate Clinical Studies        1.0 TO 4.0  TBA         TBA                          STAFF"
    assert Scraper.parse_hours(line) == "variable"
  end

  test "parse days" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.parse_days(line) == "MTW"
  end

  test "parse days [case: 'TBA']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Scraper.parse_days(line) == "TBA"
  end

  test "parse days [case: 'T W' (space)]" do
    line = "\n 40951   6203    21  Contracts II                     3.0         T W         0600 - 0800pm                Wilmarth"
    assert Scraper.parse_days(line) == "TW"
  end

  test "parse days [case: US appears in course title]" do
    line = "77506   6594    10  History of the US Constitution   3.0         TR          0350 - 0515pm                Wilmarth\n"
    assert Scraper.parse_days(line) == "TR"
  end

  test "convert times (am and pm)" do
    times_array = ["0935", "1050"]
    am_pm = "am"
    times = Scraper.convert_times(times_array, am_pm)
    assert times[0] = "0935"
    assert times[0] = "1050"

    # Just change am to pm
    am_pm = "pm"
    times = Scraper.convert_times(times_array, am_pm)
    assert times[0] = "1735"
    assert times[1] = "2250"
  end

  test "assign_times_to_days" do
    days_string = "MTW"
    times_array = ["935", "1050"]
    result_hash = Scraper.assign_times_to_days(days_string, times_array)
    assert result_hash[:day2_start] = "935"
    assert result_hash[:day2_end] = "1050"
    assert result_hash[:day3_start] = "935"
    assert result_hash[:day3_end] = "1050"
    assert result_hash[:day4_start] = "935"
    assert result_hash[:day4_end] = "1050"
  end

  test "parse times [case: both start and end are pm]" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.parse_times(line) == ["1340", "1435"]
  end

  test "parse times [case: both start and end are am]" do
    line =  "\n 40958   6214    14  Constitutional Law I             3.0         MWR         0850 - 0945am                Smith"
    assert Scraper.parse_times(line) == [850, 945]
  end

  test "parse times [case: 'TBA']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Scraper.parse_times(line) == "TBA"
  end

  test "parse times [case: 'MWR']" do
    line = "70900   6214    14  Constitutional Law I             3.0         MWR         0850 - 0945am                Fontana\n"
    assert Scraper.parse_times(line) == [850, 945]
  end

  test "parse professor" do
    line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    assert Scraper.parse_professor(line) == "Selmi"
  end

  test "parse professor 2" do
    line = "\n 43218   6254    10  Corporate Finance                2.0         R           0140 - 0340pm                Turilli"
    assert Scraper.parse_professor(line) == "Turilli"
  end

  test "parse professor [case: 'STAFF']" do
    line = "\n 41009   6696    25  Graduate Indep Legal Writing     1.0 OR 2.0  TBA         TBA                          STAFF"
    assert Scraper.parse_professor(line) == "STAFF"
  end

  test "parse additional class times (line 2)" do
    line = "\n                                                                  F           1100 - 1155am                Fairfax"
    day6_start = Scraper.parse_additional_classtimes(line)[:day6_start]
    day6_end = Scraper.parse_additional_classtimes(line)[:day6_end]
    assert day6_start = "1100", "Expected 1100, was: #{day6_start}"
    assert day6_end = "1155", "expected 1155, was: #{day6_end}"
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

    @combined_schedule = Scraper.combine_attribute_hashes(@week_schedule_1, @week_schedule_2)
    assert @combined_schedule = @expected_schedule
  end

  # This just runs every single line through the parser to find errors.
  test "[gwu_parse_crn_line] smoke test for runtime errors" do
    # spring 2015
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_spring2015.pdf"
    lines = Scraper.slice_into_lines(source.text)
    lines.each do |line|
      Scraper.gwu_parse_crn_line(line)
    end
    # fall 2015
    source = Yomu.new "https://www.schedulegw.com/gwu_test_crn_fall2015.pdf"
    lines = Scraper.slice_into_lines(source.text)
    lines.each do |line|
      Scraper.gwu_parse_crn_line(line)
    end
    # spring 2016
    source = Yomu.new "http://www.law.gwu.edu/Students/Records/Spring2016/Documents/Spring%202016%20Schedule%20with%20CRNs.pdf"
    lines = Scraper.slice_into_lines(source.text)
    lines.each do |line|
      Scraper.gwu_parse_crn_line(line)
    end
  end

  test "[gwu_parse_crn_line] crn-containing line, standard" do
    @line = "\n 40948   6203    11  Contracts II                     3.0         MTW         0140 - 0235pm                Selmi"
    @parsed_course = Scraper.gwu_parse_crn_line(@line)
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
    @parsed_course = Scraper.gwu_parse_crn_line(@line)
    assert @parsed_course[:day6_start] = 1100
    assert @parsed_course[:day6_end] = 1155
  end

  test "[gwu_parse_crn_line] - llm only v1" do
    @line = "\n                            LL.M.s Only"
    @parsed_course = Scraper.gwu_parse_crn_line(@line)
    assert @parsed_course[:llm_only] = true
  end

  test "[gwu_parse_crn_line] - llm only v2" do
    @line = "\n                            OPEN ONLY TO LLMs"
    @parsed_course = Scraper.gwu_parse_crn_line(@line)
    assert @parsed_course[:llm_only] = true
  end

  test "[gwu_parse_crn_line] - jd only" do
    @line = "\n                       (J.D.s only)                                                                        Rainey   Gardner"
    @parsed_course = Scraper.gwu_parse_crn_line(@line)
    assert @parsed_course[:jd_only] = true
  end

  test "[gwu_parse_crn_line] - alternate schedule" do
    @line = "\n                           Course meets Tuesdays and alternate Wednesdays"
    @parsed_course = Scraper.gwu_parse_crn_line(@line)
    assert @parsed_course[:alt_schedule] = true
  end

  test "self.scrape_gwu_crn_pdf total course count (coarse)" do
    ob = scrapeurls(:gwu_test_crn_spring2015)
    scraped_courses = Scraper.scrape_gwu_crn_pdf(ob)
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
    scraped_courses = Scraper.scrape_gwu_crn_pdf(ob)
    scraped_crns = scraped_courses.map {|c| c.crn }
    edge_crns.each do |ec|
      assert scraped_crns.include?(ec), "List of scraped courses did not include CRN #{ec}"
    end

  end

  test "self.scrape_gwu_crn_pdf first course spring2015" do
    ob = scrapeurls(:gwu_test_crn_spring2015)
    assert ob.semester = semesters(:spring2015)
    scraped_courses = Scraper.scrape_gwu_crn_pdf(ob)
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
    scraped_courses = Scraper.scrape_gwu_crn_pdf(ob)
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

  test "parse course chunk with two lines" do
    ob = scrapeurls(:gwu_test_crn_spring2015)
    src = Yomu.new ob.url
    course_array = Scraper.split_by_crns(src.text)
    contracts = course_array[2] # Contracts II with Fairfax (2 lines)
    # "40949   6203    12  Contracts II                     3.0         WR          0850 - 0945am                Fairfax\n                                                                  F           1100 - 1155am                Fairfax\n\n "
    @course = Scraper.parse_course_chunk(contracts)
    assert @course.course_name = "Contracts II"
    assert @course.hours = "3"
    assert @course.crn = "40949"
    assert @course.day6_start = "1100"
    assert @course.day6_end = "1155"

  end

  test "parsing times 3" do
    course_chunk = "70900   6214    14  Constitutional Law I             3.0         MWR         0850 - 0945am                Fontana\n"
    @course = Scraper.parse_course_chunk(course_chunk)
    assert @course.day1_start.nil?, "expected nil - day1, was #{@course.day1_start}"
    assert @course.day1_end.nil?, "expected nil - day1"
    assert @course.day2_start = "850"
    assert @course.day2_end = "945"
    assert @course.day3_start.nil?, "expected nil - day3"
    assert @course.day3_end.nil?, "expected nil - day3"
    assert @course.day4_start = "850"
    assert @course.day4_end = "945"
    assert @course.day5_start = "850"
    assert @course.day5_end = "945"
    assert @course.day6_start.nil?, "expected nil - day6"
    assert @course.day6_end.nil?, "expected nil - day6"
    assert @course.day7_start.nil?, "expected nil - day7"
    assert @course.day7_end.nil?, "expected nil - day7"
  end

  test "it should reject overwriting a locked attribute" do
    c = Course.second # The 'new' attributes.

    record = Course.first # the 'current' course info
    record.course_name = "This should remain"
    record.locked_attributes << "course_name"
    record.save!

    attributes_to_write = c.attributes.select { |k, v| Scraper.scrape_attributes.include?(k) }
    attributes_to_write = attributes_to_write.reject { |k, v| k == "id" }
    attributes_to_write.each do |k, v|
      record.send("#{k}=", v) unless record.locked_attributes.include?("#{k}")
    end
    record.save!

    assert record.course_name == "This should remain", "Failed to preserve a locked attribute"
    assert record.crn == c.crn, "Failed to overwrite the CRN"

  end








end

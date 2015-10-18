require 'test_helper'

class ScrapeurlTest < ActiveSupport::TestCase


  test "fixtures are valid" do
    @scrapeurl = scrapeurls(:gwu_test_crn_spring2015)
    assert @scrapeurl.valid?

    @scrapeurl = scrapeurls(:gwu_test_crn_spring2016)
    assert @scrapeurl.valid?
  end

  # The scrapeurls might be causing problems on the course scraping tests. This
  # is part of the attempt to diagnose it. (error: semester_id is unknown attribute (??))
  test "fixtures have proper associations" do
    @scrapeurl = scrapeurls(:gwu_test_crn_spring2015)
    assert @scrapeurl.semester = semesters(:spring2015)
    @scrapeurl = scrapeurls(:gwu_test_crn_spring2016)
    assert @scrapeurl.semester = semesters(:spring2016)
  end

  # Check to see if the source document has been updated since the last scrape by
  # comparing hashes
  test "source_changed?" do
    # Setup a Scrapeurl object where the URL and the hash obviously don't match.
    @scrape_url = Scrapeurl.new
    @scrape_url.school = School.find_by(name: "GWU")
    @scrape_url.semester = Semester.find_by(name: 'fall2015')
    @scrape_url.name = "gwu_test_crn_fall2015"
    @scrape_url.url = 'https://www.schedulegw.com/gwu_test_crn_fall2015.pdf'
    @scrape_url.last_checked = Time.now
    @scrape_url.last_scraped = Time.now
    @scrape_url.scrape_digest = 'not_a_valid_scrape_digest'
    @scrape_url.save!

    # Make the method find out for itself that the scrape_digests don't match.
    assert @scrape_url.source_changed?
  end


end

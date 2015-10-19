require 'test_helper'

class BooklistScraperTest < ActiveSupport::TestCase
  def setup
    # Run the scrape before each test.
    Course.delete_all
    pdf_url = scrapeurls(:gwu_test_booklist_fall2015).url
    Course.get_books(pdf_url)
  end

  # test "the truth" do
  #   assert true
  # end
  test "It should find these ISBNs" do

    # Test
    course = Course.find_by(gwid: '6210-22')
    assert course.isbn.include?("9780314279828"), "#{course.course_name} didn't include 9780314279828"
    assert course.isbn.include?("9781454815532"), "#{course.course_name} didn't include 9781454815532"



  end

end

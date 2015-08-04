require 'test_helper'

class UsermailerTest < ActionMailer::TestCase
  def setup
    # Get a user
    @user = users(:grant)

    # Make some schedules from courses
    schedules(:firstschedule).courses << courses(:evidence) << courses(:pre)
    schedules(:secondschedule).courses << courses(:evidence)

    # Give the user a few schedules
    @user.schedules << schedules(:firstschedule)
    @user.schedules << schedules(:secondschedule)

    # @schedule for sending the single email with a schedule in it.
    @schedule = users(:grant).schedules.first
  end


  test "schedule" do
    # Setup and verify a test subject

    mail = Usermailer.schedule(@user, @schedule)
    assert_equal "Your Schedule From ScheduleGW", mail.subject
    assert_equal ["gmnelson@law.gwu.edu"], mail.to
    assert_equal ["noreply@schedulegw.com"], mail.from
    assert_match "Here's the schedule you wanted", mail.body.encoded
  end

  # Tests for the email that actually makes money.
  test "moneyemail" do
    mail = Usermailer.booksemail(@user)
    assert_equal "#{@user.name}, Here's Your Booklist", mail.subject

    # Test that the email includes all of the necessary schedule names
    assert_match schedules(:firstschedule).name, mail.body.encoded
    assert_match schedules(:secondschedule).name, mail.body.encoded

    # Test that the email includes all of the necessary course names
    assert_match courses(:evidence).course_name, mail.body.encoded
    assert_match "Prof Responsibility", mail.body.encoded # .course_name doesn't encode correctly



  end

end

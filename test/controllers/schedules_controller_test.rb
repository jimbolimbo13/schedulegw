require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  test "should get schedules" do
    get :schedules
    assert_response :success
  end

end

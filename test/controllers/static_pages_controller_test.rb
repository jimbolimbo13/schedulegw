require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get security" do
    get :security
    assert_response :success
  end

end

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user fixtures are valid" do
    assert users(:grant).valid?, "user grant wasnt valid!"
  end


end

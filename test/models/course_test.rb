require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert courses(:evidence).valid?, "Evidence wasnt a valid course"
    assert courses(:pre).valid?, "PRE wasnt a valid course"
  end
end

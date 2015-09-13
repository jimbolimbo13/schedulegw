require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  def setup
    @user = users(:grant)
    @schedule = @user.build_schedule("60242,61000".split(",").map(&:to_i))
  end

  test "is valid " do
    assert @schedule.valid?
  end

end

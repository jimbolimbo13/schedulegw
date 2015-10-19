require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  def setup
    @user = users(:grant)
    @id1 = courses(:evidence).id
    @id2 = courses(:pre).id
    @schedule = @user.build_schedule("#{@id1},#{@id2}".split(",").map(&:to_i))
  end

  test "is valid " do
    assert @schedule.valid?
  end

end

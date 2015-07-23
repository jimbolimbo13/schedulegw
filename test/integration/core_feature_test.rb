require 'test_helper'

class CoreFeatureTest < ActiveSupport::TestCase
  def setup

  end

  # test "the truth" do
  #   assert true
  # end

  test "User saves a new schedule" do
    #data setup
    current_user = users(:grant)
    get_variables = "60242,61000"

    # #controller logic
    current_user.build_schedulecourse("60242,61000".split(",").map(&:to_i))
    schedule = current_user.schedules.create!(:name => "Unnamed Schedule")
    courses = get_variables.split(",").map(&:to_i)

    courses.each do |course|
      schedule.courses << Course.find_by(crn: course)
    end

    schedule.save!
    assert current_user.schedules.count = 1
  end
end

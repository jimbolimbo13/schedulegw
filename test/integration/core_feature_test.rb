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
    course_id_1 = courses(:evidence).id
    course_id_2 = courses(:pre).id
    get_variables = "#{course_id_1},#{course_id_2}"

    # #controller logic
    current_user.build_schedule("#{course_id_1},#{course_id_2}".split(",").map(&:to_i))
    schedule = current_user.schedules.create!(:name => "Unnamed Schedule")
    courses_ids = get_variables.split(",").map(&:to_i)

    courses_ids.each do |course_id|
      schedule.courses << Course.find(course_id)
    end

    schedule.save!
    assert current_user.schedules.count = 1
  end
end

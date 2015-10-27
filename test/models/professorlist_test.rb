require 'test_helper'

class ProfessorlistTest < ActiveSupport::TestCase

  test "it should assign_prof_id with the right Fairfax" do
    course = courses(:contractsIIFairfax)
    prof_id = Professorlist.assign_prof_id(course)
    assert prof_id = 13485
  end


end

class StaticPagesController < ApplicationController
  def security
    @users = User.count.to_i
    @schedules = School.find(3).schedules_created
  end

  def privacy
  end
end

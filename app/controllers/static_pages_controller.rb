class StaticPagesController < ApplicationController
  def security
    @users = User.count
    @schedules = School.find_by(:name => "GWU").schedules_created
  end

  def privacy
  end
end

class StaticPagesController < ApplicationController
  def security
    @users = User.count
    @schedules = School.find_by(:name => "GWU").schedules_created
  end

  def privacy
  end

  def terms
  end

  def confirm_terms
    if current_user && current_user.accepted_terms == true
      flash[:notice] = "You already accepted the terms, Happy Scheduling!"
      redirect_to root_path
    end
  end
end

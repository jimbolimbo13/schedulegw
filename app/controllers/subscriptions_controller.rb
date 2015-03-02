class SubscriptionsController < ApplicationController
  before_action :require_logged_in



  def create
    # POST goes here
    @course_ids = create_params[:course_ids].map! { |x| x.to_i }

    @user = current_user

    @user.subscribed_ids = @course_ids
    @user.save!

    flash[:notice] = "Success"
    redirect_to subscriptions_path
  end

  def new
  end

  def update
  end

  def show
  end

  def index
    @schedules = current_user.schedules.all ? current_user.schedules.all : nil
    @subscriptions = current_user.subscribed_ids ? current_user.subscribed_ids : []

    @courses = current_user.schedules.first.courses ? current_user.schedules.first.courses : nil

    # @schedules.each do |schedule|
    #   @courses << schedule.courses
    # end



  end


  private 

    def create_params
      params.require(:subscriptions).permit(:course_id, :course_ids => [])
    end

    def require_logged_in
      redirect_to security_path unless current_user
    end
end

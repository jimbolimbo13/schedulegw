class SubscriptionsController < ApplicationController
  before_action :require_logged_in



  def create
    # POST goes here
    @course_ids = create_params[:course_ids].map! { |x| x.to_i }

    @user = current_user

    @user.subscribed_ids = @course_ids
    @user.save!

    flash[:notice] = "Updated!"
    redirect_to subscriptions_path
  end

  def new
  end

  def update
  end

  def show
  end

  def index
    @user = current_user
    @subscriptions = current_user.subscribed_ids ? current_user.subscribed_ids : []

    if @user.schedules.count > 0
      @allcourses = @user.schedules.first.courses

      @user.schedules.each do |this_s|
        @allcourses = @allcourses + this_s.courses unless this_s.courses == @allcourses
      end
    end


  end


  private

    def create_params
      params.require(:subscriptions).permit(:course_id, :course_ids => [])
    end

    def require_logged_in
      redirect_to security_path unless current_user
    end
end

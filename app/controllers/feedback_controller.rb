class FeedbackController < ApplicationController
  before_action :require_admin, except: [:new, :update]

  def new
    @feedback = Feedback.new
    @booklistsuggestion = Booklistsuggestion.new
  end

  def update
    @feedback = Feedback.create(feedback_params)
    @feedback.user = current_user if current_user
    @feedback.resolved = false

    if @feedback.save!
      respond_to do |format|
        flash[:notice] = current_user ? "Feedback received, thanks #{current_user.name}" : "Feedback received!"
        format.html {redirect_to root_path }
      end
    end
  end

  def resolve
    if current_user.admin?
      @feedback = Feedback.find(params[:feedback_id])
      if @feedback.update_attribute('resolved', true)
        respond_to do |format|
          flash[:notice] = "Feedback Marked as Resolved"
          format.html { redirect_to courses_url }
          format.json { head :no_content }
        end
      end
    end
  end

  private
    def require_admin
      redirect_to root_path unless current_user && current_user.admin == true
    end

    def feedback_params
      params.require(:feedback).permit(	:crn,
                    :gwid,
                    :section,
                    :comment
                    )
    end


end

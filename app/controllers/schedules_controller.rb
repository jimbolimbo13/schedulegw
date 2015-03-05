class SchedulesController < ApplicationController
	
	before_action :check_login
  before_action :require_permission, only: [:edit, :update, :destroy]


  def index
  	@schedules = current_user.schedules

  end

  def create
  	#build new schedule, send array of course unique by school ids to users build_schedule
  	current_user.build_schedule(schedule_params[:courses].split(",").map(&:to_i)) 
  	render json: {message: 'Dope'}, status: 200

  end

  def edit
  	@schedule = Schedule.find(params[:id]) 
  end

  def show
  	@schedule = Schedule.find(params[:id]) 
  end

   def update
    @schedule = Schedule.find(params[:id])
    
    if @schedule.update(update_subscription_params)
    	flash[:notice] = "Updated."
    	redirect_to schedules_path
    end

  end

  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy
    respond_to do |format|
      flash[:notice] = "Schedule Deleted"
      format.html { redirect_to schedules_url }
      format.json { head :no_content }
    end
  end


  private 

  	def schedule_params
		params.permit(:courses, :course_ids => [])
	end

	def update_subscription_params 
		params.require(:schedule).permit(:name, :course_ids => [])
	end

	def require_permission
      if current_user != Schedule.find(params[:id]).user
      flash[:warning] = "Sorry, something went wrong."
      redirect_to root_path
      end
    end

    def check_login
      unless current_user
        flash[:warning] = "Please login."
        redirect_to signin_path
      end
    end

end

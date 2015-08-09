class SchedulesController < ApplicationController

	before_action :check_login
  before_action :require_permission, only: [:edit, :update, :destroy, :show]


  def index
  	@schedules = current_user.schedules
  end

  def create
  	#build new schedule, send array of course unique by school ids to users build_schedule
    # schedule_params[:courses].split(",").map(&:to_i)
  	schedule = current_user.schedules.create!(:name => "Unnamed Schedule")
    courses = schedule_params[:courses].split(",").map(&:to_i)

    courses.each do |course|
      schedule.courses << Course.find_by(crn: course)
    end

    schedule.save!

    #update stat: total number of times the next button was pressed.
    school = School.find(current_user.school.id)
    school.schedules_created = school.schedules_created + 1
    school.save!

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

  def send_schedule_email
    schedule_id = Schedule.find(params[:schedule]).id

		if SendScheduleWorker.perform_async(current_user.id, schedule_id)
      flash[:notice] = "Email Sent to #{current_user.email}."
      redirect_to schedules_path
    else
      flash[:danger] = "Email didn't send - try again."
      redirect_to schedules_path
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

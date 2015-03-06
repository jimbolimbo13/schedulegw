class CoursesController < ApplicationController
	before_action :require_admin

	#GET /courses/1/edit
	def edit
		@course = Course.find(params[:id])
	end

	#GET /courses
	def index
		@courses = Course.all
		@stats = [];
		@stats.push( {name: 'Users', value: User.count.to_i} );
		@stats.push( {name: 'Schedules', value: Schedule.count.to_i} )
		
		@new_users = User.select(:id, :name, :email).order(created_at: :desc).first(20)

	end

	def show 
		@course = Course.find(params[:id])
	end

	def new
		@course = Course.new
	end

	def update 
		@course = Course.find(params[:id])
		respond_to do |format|
	      if @course.update(course_params)
	        flash[:notice] = "Successfully updated this item."
	        format.html { redirect_to '/courses' }
	        format.json { render :index, status: :ok, location: @course }
	      else
	        format.html { render :index }
	        format.json { render json: @course.errors, status: :unprocessable_entity }
	      end
	    end
	end


	private
		def require_admin
			redirect_to root_path unless current_user && current_user.admin == true
		end

		def course_params
			params.require(:course).permit(	:crn, 
											:gwid, 
											:section, 
											:course_name, 
											:professor, 
											:hours, 
											:days, 
											:llm_only,
											:jd_only,
											:course_name_2,
											:alt_schedule,
											:additional_info,
											:final_date,
											:final_time,
											:manual_lock,
											)
		end

end

class VisitorsController < ApplicationController
	before_action :check_login
	before_action :check_school

	def index
		if params[:schedule] 
			@schedule = current_user.schedules.find_by(id: params[:schedule].to_i)
			flash[:notice] = "Loading Schedule"
		end
	end

	def gwsbadata
		@data = Course.all.map { |course| {:professor => course.professor, :name => course.course_name} }
	end

	def check_login
		redirect_to signin_path unless current_user
	end

	def check_school
		if current_user.school.name == 'none'
			redirect_to security_path 
		end
	end

end

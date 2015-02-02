class CoursesController < ApplicationController
	before_action :require_admin


	#GET /courses/1/edit
	def edit
		@course = Course.find(params[:id])
	end

	#GET /courses
	def index
		@courses = Course.all
	end


	private
		def require_admin
			redirect_to root_path unless current_user && current_user.admin == true
		end

end

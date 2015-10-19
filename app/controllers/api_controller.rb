class ApiController < ApplicationController
	def courses
		expires_in 10.minutes, :public => true
		school_name = current_user.school.name.to_s

		# Check to see if semester is defined; if not make it the most recent one.
		if params[:semester].present?
			@semester = Semester.find(params[:semester]) || Semester.last
		else
			@semester = Semester.last
		end

		# Grab the courses to return as JSON
		@courses = Course.all.where(school: school_name, semester_id: @semester.id)

		respond_to do |format|
			format.json { render :json => @courses }
			format.html #index.html.erb
		end
	end

	def whoami
		if current_user
			respond_to do |format|
				format.json {render :json => current_user}
			end
		end
	end

	private

end

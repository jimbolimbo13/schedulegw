class ApiController < ApplicationController
	def courses
		@school = current_user.school.name
		@courses = Course.all.where(school: @school)

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

class ApiController < ApplicationController
	def courses
		@courses = Course.all

		respond_to do |format|
			format.json { render :json => @courses }
			format.html #index.html.erb
		end
	end

	private 
		def params 
			
		end
end

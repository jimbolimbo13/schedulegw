class VisitorsController < ApplicationController
	def index 
		if current_user 
			@status = 'logged_in'
		else
			@status = 'logged_out'
		end
	end
end

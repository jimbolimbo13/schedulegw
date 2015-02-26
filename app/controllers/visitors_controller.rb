class VisitorsController < ApplicationController
	before_action :check_login

	
	def check_login
		redirect_to signin_path unless current_user
	end
end

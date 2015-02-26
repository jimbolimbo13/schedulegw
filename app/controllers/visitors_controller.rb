class VisitorsController < ApplicationController
	before_action :check_login
	before_action :check_school


	def check_login
		redirect_to signin_path unless current_user
	end

	def check_school
		if current_user.school.name == 'none'
			reset_session
			redirect_to security_path
		end
	end

end

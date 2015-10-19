class VisitorsController < ApplicationController
	before_action :check_login
	before_action :check_if_accepted_terms, except: [:accepted_terms]

	def index
		if params[:schedule]
			@schedule = current_user.schedules.find_by(id: params[:schedule].to_i)
		end
	end

	def gwsbadata
		@data = Course.all.map { |course| {:professor => course.professor, :name => course.course_name} }
	end

	def check_login
		redirect_to security_path if current_user.nil? || current_user.school.name == 'none'
	end

	def check_if_accepted_terms
		redirect_to confirm_terms_path if current_user.accepted_terms == false
	end

	def accepted_terms
		@user = current_user
		@user.accepted_terms = true
		if @user.save!
			flash[:notice] = "Happy Scheduling!"
			redirect_to root_path
		end
	end


end

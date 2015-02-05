class ResultController < ApplicationController
	before_action :check_login

	def index
		@classes = params[:classes]

	end

	private 
		def check_login 
			redirect_to signin_path unless current_user 
		end

		def schedule_params
		 	params.require(:schedule).permit(:classes)
	    end
end

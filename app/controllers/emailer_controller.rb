class EmailerController < ApplicationController
  before_action :require_admin

  def send_email
    @round = params[:round].to_i
    BroadcastEmailWorker.perform_async(@round)
  end

  private
    def require_admin
      redirect_to root_path unless current_user && current_user.admin == true
    end

end

class ScraperController < ApplicationController
  before_action :require_admin

  def scrape

    case params[:source]
    when 'booklist'
      BooklistScraperWorker.perform_async(current_user.school.id) unless current_user.school.booklist_url.nil?
    end

    respond_to do |format|
      format.json { "success" }
    end

	end

  private
    def require_admin
      redirect_to root_path unless current_user && current_user.admin == true
    end

end

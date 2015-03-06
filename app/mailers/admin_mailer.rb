class AdminMailer < ApplicationMailer
	include Roadie::Rails::Mailer

  def scrape_complete(email_data)
  	@admin = 'grantmnelsn@gmail.com'
    @final_times = email_data[:final_times]
    @final_dates = email_data[:final_dates]
  	@school = email_data[:school]
    roadie_mail to: @admin, subject: "! Scrape Data Changed for #{@school}"
  end

end

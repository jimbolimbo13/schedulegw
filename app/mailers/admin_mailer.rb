class AdminMailer < ApplicationMailer
	include Roadie::Rails::Mailer

  def scrape_complete(email_data)
  	@admin = 'grantmnelsn@gmail.com'
    @final_times = email_data[:final_times]
    @final_dates = email_data[:final_dates]
  	@school = email_data[:school]
    roadie_mail to: @admin, subject: "! Scrape Data Changed for #{@school}"
  end

  def error_report(errors)
    @admin = 'grantmnelsn@gmail.com'
    @errors = errors
    roadie_mail to: @admin, subject: "!  SCRAPE ERROR - ADDRESS IMMEDIATELY  !"
  end

	def feedback_notification(feedback_id)
		@feedback = Feedback.find(feedback_id)
		@admin = User.find_by(email: 'gmnelson@law.gwu.edu')
		roadie_mail to: @admin.email, subject: "[ScheduleGW] -- Unwanted Feedback!"
	end

end

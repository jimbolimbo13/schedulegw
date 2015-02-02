class AdminMailer < ApplicationMailer
	include Roadie::Rails::Mailer

  def scrape_complete(school)
  	@admin = 'grantmnelsn@gmail.com'
  	@school = school
    roadie_mail to: @admin, subject: "Scrape Complete #{school}"
  end

end

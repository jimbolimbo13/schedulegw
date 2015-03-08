class Usermailer < ApplicationMailer
  include Roadie::Rails::Mailer
  default from: "noreply@meansdatabase.com"
  
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.usermailer.schedule.subject
  #
  def schedule(user)
    
    roadie_mail to: user.email, subject: "Your Schedule From ScheduleGW"
  end

end

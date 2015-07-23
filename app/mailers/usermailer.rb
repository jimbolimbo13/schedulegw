class Usermailer < ApplicationMailer
  include Roadie::Rails::Mailer
  default from: "noreply@schedulegw.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.usermailer.schedule.subject
  #

  def schedule(user, schedule)
    @user = user
    @courses = schedule.courses
    @schedule = schedule

    school = School.find(user.school.id)
    school.emails_sent = school.emails_sent + 1
    school.save!

    roadie_mail to: user.email, subject: "Your Schedule From ScheduleGW"
  end

  def booksemail(user)
    @user = user
    roadie_mail to: user.email, subject: "#{user.name}, Here's Your Booklist"
  end

end

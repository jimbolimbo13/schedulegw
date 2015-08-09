class Usermailer < ApplicationMailer
  include Roadie::Rails::Mailer
  default from: "noreply@schedulegw.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.usermailer.schedule.subject
  #

  def schedule(user_id, schedule_id)
    @user = User.find(user_id)
    @schedule = Schedule.find(schedule_id)
    @courses = @schedule.courses

    school = School.find(@user.school.id)
    school.emails_sent = school.emails_sent + 1
    school.save!

    roadie_mail to: @user.email, subject: "Your Schedule From ScheduleGW"
  end

  def booksemail(user)
    @user = user
    roadie_mail to: user.email, subject: "Fall 2015 Booklist Links for #{user.name}"
  end

end

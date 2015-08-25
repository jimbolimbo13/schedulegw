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

    school = School.find(@user.school.id)
    school.emails_sent = school.emails_sent + 1
    school.save!

    roadie_mail to: @user.email, subject: "Your Schedule From ScheduleGW"
  end

  def booksemail1(user)
    @user = user

    if user.last_email_blast < 60.hours.ago
      roadie_mail to: user.email, subject: "Fall 2015 Booklist Links for #{user.name}"
      # Log the time this was sent so we don't email the same user more than once every 3 days.
      @user.last_email_blast = Time.now
      @user.save!
      sleep(3) # To avoid bombarding Google's SMTP Servers.
    end
  end

  def booksemail2(user)
    @user = user

    if user.last_email_blast < 60.hours.ago
      roadie_mail to: user.email, subject: "[2-day Shipping Warning] Fall 2015 Booklist Links for #{user.name}"
      # Log the time this was sent so we don't email the same user more than once every 3 days.
      @user.last_email_blast = Time.now
      @user.save!
      sleep(3) # To avoid bombarding Google's SMTP Servers.
    end
  end

  def booksemail3(user)
    @user = user

    if user.last_email_blast < 60.hours.ago
      roadie_mail to: user.email, subject: "[Final Email] #{user.name}, Links to the Books For Your Classes"
      # Log the time this was sent so we don't email the same user more than once every 3 days.
      @user.last_email_blast = Time.now
      @user.save!
      sleep(3) # To avoid bombarding Google's SMTP Servers.
    end
  end

end

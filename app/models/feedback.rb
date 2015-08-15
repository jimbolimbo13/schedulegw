class Feedback < ActiveRecord::Base
  belongs_to :user
  after_create :email_admin

  def email_admin
    # Email the admin.
    AdminMailer.feedback_notification(self).deliver_now unless self.blank?
  end

  def blank?
    return true if
          self.comment = '' &&
          self.crn = '' &&
          self.section = '' &&
          self.gwid = ''

    return false
  end

end

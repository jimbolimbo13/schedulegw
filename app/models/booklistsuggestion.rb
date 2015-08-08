class Booklistsuggestion < ActiveRecord::Base
  before_save :auto_add_if_admin
  belongs_to :user


  # Automatically adds the suggestion if the user submitting it is an admin.
  def auto_add_if_admin
    if self.user && self.user.admin?
      @course_1 = Course.where("gwid = ? AND section = ?", self.gwid, self.section).first if (self.gwid && self.section)
      # Check to see if crn finds anything
      @course_2 = Course.find_by(crn: self.crn) unless self.crn.empty?

      # use the course found from gwid/section unless we found two and they aren't the same.
      @course = @course_1 unless (@course_1 && @course_2) && @course_1 != @course_2

      @course.pinned_isbn << self.isbn
      @course.pinned_isbn.uniq!

      # A bit of code smell to save this here
      @course.save!
    end
  end
end

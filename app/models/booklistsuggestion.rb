class Booklistsuggestion < ActiveRecord::Base
  before_save :auto_add_if_admin
  belongs_to :user


  # Admin can accept suggestions, this method applies the suggestion.
  def accept_suggestion
    self.pin_isbn(self.isbn)
  end

  # Given an isbn, add it to the list of pinned ISBNs
  def pin_isbn(isbn)
    @course = Course.where("gwid = ? AND section = ?", self.gwid, self.section).first if (self.gwid && self.section)
    @course.pinned_isbn << self.isbn
    @course.pinned_isbn.uniq!
    @course.save!
  end


  # Automatically adds the suggestion if the user submitting it is an admin.
  def auto_add_if_admin
    if self.user && self.user.admin?
      self.pin_isbn(self.isbn)
    end
  end
end

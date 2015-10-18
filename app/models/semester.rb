class Semester < ActiveRecord::Base
  has_many :courses
  has_many :scrapeurls

end

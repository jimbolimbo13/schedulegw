class Semester < ActiveRecord::Base
  has_many :courses
  has_many :schools
  has_many :scrapeurls

end

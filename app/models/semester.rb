class Semester < ActiveRecord::Base
  has_many :courses
  has_many :scrapeurls

  def display_name
    name.capitalize
  end


end

class School < ActiveRecord::Base
	has_many :users
	belongs_to :semester
  serialize :final_time_options, Array
  serialize :final_date_options, Array

end

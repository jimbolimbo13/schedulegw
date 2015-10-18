class School < ActiveRecord::Base
	has_many :users
	has_many :scrapeurls
  serialize :final_time_options, Array
  serialize :final_date_options, Array

end

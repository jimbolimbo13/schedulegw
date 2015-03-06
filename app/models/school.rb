class School < ActiveRecord::Base
	has_many :users
  serialize :final_time_options, Array
  serialize :final_date_options, Array
  

end

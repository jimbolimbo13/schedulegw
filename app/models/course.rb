class Course < ActiveRecord::Base
	has_many :schedules
	has_many :users, through: :schedules

	has_many :subscriptions
	has_many :users, through: :subscriptions



	

	def self.scrape
		load Dir.pwd + '/app/scraper/GWU_scrape.rb'
	end

end

class Course < ActiveRecord::Base

  #relationship to schedules
  has_many :courseschedules
  has_many :schedules, through: :courseschedules


  #possibly:
  belongs_to :schools

	has_many :subscriptions
	has_many :users, through: :subscriptions


	

	def self.scrape
    #load the scrapers here.
		load Dir.pwd + '/GWU_scrape.rb'
	end

end

class User < ActiveRecord::Base
	belongs_to :school
	has_many :schedules
	has_many :courses, through: :schedules

	has_many :subscriptions 
	has_many :courses, through: :subscriptions

	serialize :subscribed_ids, Array 


  def self.create_with_omniauth(auth)
	    create! do |user|
	      	user.provider = auth['provider']
		    user.uid = auth['uid']
		    if auth['info']
		      	user.name = auth['info']['name'] || ""
		      	email = auth['info']['email']
  				stub = email.slice(/@.+/)
  				@school = School.find_by(email_stub: stub) ? School.find_by(email_stub: stub) : School.find_by(name: 'none')
  				if email == 'gmnelson@law.gwu.edu'
  					user.admin = true
  				end
		      	user.school = @school
		      	user.email = email
		    end
	    end
  end

  def build_schedule(courses)
  	# courses is an array containing crns / school unique identifiers for each course in this schedule
		@crns = courses
	  	@schedule = self.schedules.build
	  	
	  	@crns.each do |crn|
	  		@course = Course.find_by(crn: crn) ? Course.find_by(crn: crn) : nil
	  		@schedule.courses << @course
	  	end

	  	@schedule.save

	end

	def update_subscription_prefs(course_ids)
		self.subscription_ids << course_ids

	end


	

end

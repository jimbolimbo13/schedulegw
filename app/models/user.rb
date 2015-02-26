class User < ActiveRecord::Base
	belongs_to :school
	#has_many :schedules



  def self.create_with_omniauth(auth)
    create! do |user|
      	user.provider = auth['provider']
	    user.uid = auth['uid']
	    if auth['info']
	      user.name = auth['info']['name'] || ""
	      email = auth['info']['email']
	      stub = email.slice(/@.+/)
	      @school = School.find_by(email_stub: stub) ? School.find_by(email_stub: stub) : School.find_by(name: 'none')
	      user.school = @school
	      user.email = email
	    end
    end
  end



	

end

class Schedule < ActiveRecord::Base
	default_scope { order('created_at DESC') }

  belongs_to :user
  
  #schedule to courses relations
  has_many :courseschedules
  has_many :courses, through: :courseschedules

  before_create :create_unique_string

  def create_unique_string
    @string = ('a'..'z').to_a.shuffle[0,15].join
    Schedule.find_by(:unique_string => @string) ? self.create_unique_string : self.unique_string = @string
  end


end

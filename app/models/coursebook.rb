class Coursebook < ActiveRecord::Base
  belongs_to :course
  belongs_to :listbook
end

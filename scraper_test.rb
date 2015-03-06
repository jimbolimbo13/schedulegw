require 'rubygems'
require 'active_record'
require 'pg' # or 'pg' or 'sqlite3'
require 'yomu'

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql', # or 'postgresql' or 'sqlite3'
  database: 'omniauth_development',
  username: 'omniauth',
  host: 'localhost'
)

# Choose the Destination model for the scrape tested below.
class Course < ActiveRecord::Base
end

crn_text = Yomu.new 'http://www.law.gwu.edu/Students/Records/Fall2015/Documents/Fall%202015%20Schedule%20of%20Classes%20with%20CRNs.pdf'

puts Course.first.inspect

puts crn_text.text



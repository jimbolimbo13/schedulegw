source 'https://rubygems.org'
ruby '2.2.0'
gem 'rails', '4.2'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'bootstrap-sass'
gem 'high_voltage'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'pg'
gem 'figaro' #puts env variables in config/application.yml
gem 'yomu' #pulls pdf to text, essential to scraper.
gem 'roadie-rails' #inlines style for emails
gem 'sidekiq' # background workers
gem 'sinatra', :require => nil #required for Sidekiq monitoring panel.
gem 'vacuum' #Amazon Product API wrapper
gem 'nokogiri' #HTTP parser
gem 'unicorn', '4.8.3' #Unicorn for Heroku in production. for large amounts of traffic.
gem 'appsignal' # For monitoring and error reporting

group :development do
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'hub', :require=>nil
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'letter_opener'
end

group :production do
  gem 'unicorn', '4.8.3' #Unicorn for Heroku in production. for large amounts of traffic.
  gem 'rails_12factor'
  gem 'thin'
  gem 'heroku_rails_deflate' #gzipper for Heroku, reduces pageload time and makes Google happy
end

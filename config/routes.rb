Rails.application.routes.draw do
  get 'emailer/send_email'

  resources :users

  root 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'static_pages#security'
  post '/iaccept' => 'visitors#accepted_terms'

  #subscriptions stuff
  get 'subscriptions' => 'subscriptions#index'
  post 'subscriptions' => 'subscriptions#create'

  get 'subscriptions/create'
  get 'subscriptions/new'
  get 'subscriptions/update'
  get 'subscriptions/show'

  #next pages
  get '/schedules' => 'schedules#index'
  get '/schedules/create' => 'schedules#create'
  get '/schedules/send_schedule_email' => 'schedules#send_schedule_email'
  resources :schedules
  get '/schedules/:id/edit' => 'schedules#edit'
  get '/schedules/:id/show' => 'schedules#show'

  # API
  get '/api/courses/:school', to: 'api#courses'
  get '/api/whoami', to: 'api#whoami'


  # manual editing etc.
  get '/courses/gwufinals' => 'courses#gwufinals'
  resources :courses

  post 'scrape' => 'scraper#scrape'

  post 'send_email' => 'emailer#send_email'

  # allow people to add suggestions to booklistsuggestions model
  get 'addtobooklist/index'
  get 'addtobooklist/new'
  patch 'addtobooklist/update'
  post 'addtobooklist/update'
  post 'addtobooklist/accept_suggestion'
  delete 'addtobooklist/destroy'
  get 'addtobooklist/get_course'

  # Feedback Stuff
  get 'feedback' => 'feedback#new'
  post 'feedback/update'
  post 'feedback/resolve'
  delete 'feedback/destroy'


  #staticpages
  get 'security' => 'static_pages#security'
  get 'privacy' => 'static_pages#privacy'
  get 'terms' => 'static_pages#terms'
  get 'confirm_terms' => 'static_pages#confirm_terms'

  #GWSBA stuff
  get 'gwsbadata' => 'visitors#gwsbadata'

  #for Sidekiq Background Worker monitoring
  require 'sidekiq/web'
  require 'admin_constraint'
  mount Sidekiq::Web => '/sidekiq', :constraints => AdminConstraint.new

end

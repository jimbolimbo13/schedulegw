Rails.application.routes.draw do


  resources :users
  resources :courses

  root 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'static_pages#security'


  #staticpages 
  get 'security' => 'static_pages#security'
  get 'privacy' => 'static_pages#privacy'

  #API
  get '/api/courses/:school', to: 'api#courses'
  get '/api/whoami', to: 'api#whoami'

  #manual editing etc. 
  get '/courses/:id/edit' => 'courses#edit'
  get '/courses' => 'courses#index'


end

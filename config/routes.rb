Rails.application.routes.draw do
  resources :users
  resources :courses

  root 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
  get '/api/courses' => 'api#courses'

  #manual editing etc. 
  get '/courses/:id/edit' => 'courses#edit'
  get '/courses' => 'courses#index'


end

# frozen_string_literal: true

Rails.application.routes.draw do
  root controller: "charts", action: "index"

  get 'charts/index'
  get 'charts/cnt_per_weekday'
  get 'charts/distance_per_year'
  get 'charts/duration_per_year'
  get 'charts/elevation_per_year'
  get 'charts/cnt_per_year'
  get 'charts/distance_buckets'
  get 'charts/hour_per_day'

  resources :sport_sessions, only: [:index, :destroy]

  get 'charts', to: 'charts#index'
  #get 'sport_sessions', to: 'sport_sessions#index'
  get 'sport_sessions/search', to: 'sport_sessions#search'
  get 'cities', to: 'cities#index'

  get 'imports', to: 'imports#index'
  post 'imports/create'

  resources :sport_sessions, only: [:index, :show, :destroy]

  get 'courses', to: 'courses#index'
  post 'courses/create_from_session'
  resources :courses, only: [:index, :show, :new, :destroy] do
    resources :session, only: [:destroy, :create]
  
    get 'matching_sessions'
    post 'add_all_matching_sessions'
  end

  get 'trace_matcher', to: 'trace_matcher#index'


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

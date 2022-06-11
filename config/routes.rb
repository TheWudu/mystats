# frozen_string_literal: true

Rails.application.routes.draw do
  get 'charts/index'
  get 'charts/cnt_per_weekday'
  get 'charts/distance_per_year'
  get 'charts/duration_per_year'
  get 'charts/elevation_per_year'
  get 'charts/cnt_per_year'
  get 'charts/distance_buckets'
  get 'charts/hour_per_day'

  get 'sessions/index'

  get 'charts', to: 'charts#index'
  get 'sessions', to: 'sessions#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

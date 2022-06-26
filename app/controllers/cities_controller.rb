# frozen_string_literal: true

require 'repositories/statistics/mongo_db'
require 'repositories/sessions/mongo_db'
require 'sport_type'

class CitiesController < ApplicationController
  def index
    @cities = cities_repo.fetch(
      name: params[:name],
      latitude: params[:latitude],
      longitude: params[:longitude],
      timezone: params[:timezone]
    ).to_a
  end

  def cities_repo
    Repositories::Cities::MongoDb.new
  end
end

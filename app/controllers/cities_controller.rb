# frozen_string_literal: true

require 'sport_type'

class CitiesController < ApplicationController
  def index
    @cities = cities_repo.fetch(
      name:      params[:name],
      latitude:  params[:latitude],
      longitude: params[:longitude],
      timezone:  params[:timezone]
    ).to_a
  end

  def cities_repo
    Repositories::Cities
  end
end

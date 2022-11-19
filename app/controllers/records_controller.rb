# frozen_string_literal: true

require 'repositories/records/mongo_db'

class RecordsController < ApplicationController
  before_action :filters
  before_action :records_filters

  def records_filters
    @path_method = 'records_index_path'
    @show_filters[:month] = false
    @show_filters[:group_by] = true

    @possible_groups = %w[year year,month year,sport_type sport_type]
  end

  def index
    @records_params = {
      group_by: params[:group_by]
    }.merge(@filter_params)
  end

  def distance_per_month
    render json: Repositories::Records.distance_per_month(years:, sport_types:)
  end

  def distance_per_week
    render json: Repositories::Records.distance_per_week(years:, sport_types:)
  end

  def distance
    render json: Repositories::Records.distance(years:, sport_types:)
  end

  def average_pace
    render json: Repositories::Records.average_pace(years:, sport_types:)
  end
  
  def vam
    render json: Repositories::Records.vam(years:, sport_types:)
  end
end

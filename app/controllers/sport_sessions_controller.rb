# frozen_string_literal: true

require 'repositories/statistics/mongo_db'
require 'repositories/sport_sessions'
require 'sport_type'

class SportSessionsController < ApplicationController
  before_action :filters
  before_action :session_filters

  def session_filters
    @session_params       = session_params
    @path_method          = "sport_sessions_path"
  end

  def index
    @sport_sessions = sport_sessions_repo.fetch(
      text: params[:text],
      years: years,
      months: months,
      sport_type_ids: sport_type_ids
    )
  end
  
  def destroy
    sport_sessions_repo.delete(id: params[:id])

    redirect_to sport_sessions_path(@filter_params), status: 303
  end


  def session_params
    {
      text: params[:text]
    }
  end

  def sport_sessions_repo
    Repositories::SportSessions
  end

  def group_by
    (params[:group_by]&.split(',') || ['year']).each_with_object({}) do |v, h|
      h[v] = "$#{v}"
    end
  end

  def statistics
    @statistics ||= Repositories::Statistics::MongoDb.new(
      years: years,
      sport_type_ids: sport_type_ids,
      group_by: group_by
    )
  end
end

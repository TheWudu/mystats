# frozen_string_literal: true

require 'repositories/statistics/mongo_db'
require 'repositories/sport_sessions'
require 'sport_type'

class SessionsController < ApplicationController
  before_action :filter_params

  def filter_params
    @session_params       = session_params
    @possible_years       = statistics.possible_years
    @possible_sport_types = statistics.possible_sport_types
  end

  def index # rubocop:disable Metrics/AbcSize
    @sessions = sessions_repo.fetch(
      text: params[:text],
      years: years,
      months: months,
      sport_type_ids: sport_type_ids
    )
  end

  def session_params
    params.reverse_merge!(
      month: Time.now.month.to_s,
      year: Time.now.year.to_s
    )
    {
      year: params[:year],
      month: params[:month],
      sport_type_id: params[:sport_type_id],
      text: params[:text]
    }
  end

  def sessions_repo
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

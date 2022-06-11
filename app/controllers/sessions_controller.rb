# frozen_string_literal: true

require 'repositories/statistics/mongo_db'
require 'repositories/sessions/mongo_db'
require 'sport_type'

class SessionsController < ApplicationController
  def index # rubocop:disable Metrics/AbcSize
    params.reverse_merge!(
      month: Time.now.month.to_s,
      year: Time.now.year.to_s
    )
    @session_params = {
      year: params[:year],
      month: params[:month],
      sport_type_id: params[:sport_type_id]
    }

    @possible_years       = statistics.possible_years
    @possible_sport_types = statistics.possible_sport_types

    @sessions = sessions_repo.fetch.map do |session|
      session.merge(
        start_time: session['start_time'].in_time_zone(session['timezone']),
        sport: SportType.for(id: session['sport_type_id']),
        distance: (session['distance'] / 1000.0).round(2)
      )
    end
  end

  def sessions_repo
    @sessions_repo ||= Repositories::Sessions::MongoDb.new(
      years: years,
      months: months,
      sport_type_ids: sport_type_ids
    )
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

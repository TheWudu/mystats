# frozen_string_literal: true

require 'repositories/statistics/mongo_db'
require 'repositories/sport_sessions'
require 'sport_type'

class SportSessionsController < ApplicationController
  before_action :filters
  before_action :session_filters

  def session_filters
    @session_params       = session_params
    @path_method          = 'sport_sessions_path'
  end

  def index
    @sport_sessions = sport_sessions_repo.fetch(
      text:        params[:text],
      years:,
      months:,
      sport_types:
    )
  end

  def show
    @sport_session = Repositories::SportSessions.find_by_id(id: params[:id])
    @course = Repositories::Courses.find_by_session_id(id: @sport_session.id)
    @split_table = UseCases::Traces::SplitTable.new(trace: @sport_session.trace).run
    @elevation_chart = elevation_chart(@sport_session)
    @heart_rate_chart = heart_rate_chart(@sport_session)
  end

  def matching_courses
    @sport_session = Repositories::SportSessions.find_by_id(id: params[:sport_session_id])
    @matched_courses = matched_courses(@sport_session)

    render 'sport_sessions/_matching_courses'
  end

  def matched_courses(sport_session)
    courses = courses_with_similar_distance(sport_session.distance)
    matching_courses = analyse_match_rate(sport_session, courses)
    matching_courses.compact.sort_by { |c| c[:course].name }
  end

  def courses_with_similar_distance(distance)
    Repositories::Courses.find_by_distance(distance__gte: distance - 250,
                                           distance__lte: distance + 250)
  end

  def analyse_match_rate(sport_session, courses)
    courses.each_with_object([]) do |course, ary|
      matcher = UseCases::Traces::Matcher.new(trace1: course.trace, trace2: sport_session.trace)
      matcher.analyse
      ary << { course:, match_rate: matcher.match_in_percent } if matcher.matching?
    end
  end

  def elevation_chart(sport_session)
    sport_session.trace.each_with_object({}) do |p, h|
      key = p['time'].in_time_zone(sport_session.timezone).strftime('%H:%M:%S')
      h[key] = p['ele'].to_f.round(2)
    end
  end

  def heart_rate_chart(sport_session)
    return unless sport_session.trace.first['hr']

    avg_hr      = nil
    rolling_avg = {}
    hr = sport_session.trace.each_with_object({}) do |p, h|
      key = p['time'].in_time_zone(sport_session.timezone).strftime('%H:%M:%S')
      h[key] = p['hr'] if p['hr']
      rolling_avg[key] = ((h.values.sum + p['hr']).to_f / (h.count + 1)).round(1)
    end
    avg_val = hr.values.sum / hr.count
    avg = hr.each_with_object({}) { |(k,v),h| h[k] = avg_val  }
    @heart_rate_min = hr.values.min
    @heart_rate_max = hr.values.max

    [
      { name: "heart rate", data: hr },
      { name: "rolling avg hr", data: rolling_avg },
      { name: "avg hr", data: avg }
    ]
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
      years:,
      sport_types:,
      group_by:
    )
  end
end

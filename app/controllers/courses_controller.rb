# frozen_string_literal: true

require 'repositories/sport_sessions'
require 'repositories/courses'

class CoursesController < ApplicationController
  before_action :filters

  def index
    @courses = Repositories::Courses.fetch
  end

  def show
    @course = Repositories::Courses.find(id: params[:id])
    @assigned_sessions = assigned_sessions(@course)
    @assigned_sessions_durations = duration_chart_data(@assigned_sessions)
    slow_fast = @assigned_sessions.sort_by { |sport_session| sport_session.duration / sport_session.distance }
    @fastest_session_id   = slow_fast.first.id
    @slowest_session_id   = slow_fast.last.id

    @course_stats = stats_from_assigned(@assigned_sessions)

    @trace = @assigned_sessions.first.trace
  end

  def matching_sessions
    @course = Repositories::Courses.find(id: params[:course_id])
    @matched_sessions = matched_sessions(@course)
    @assigned_session_id = @course.session_ids.first

    render 'courses/_matching_sessions'
  end

  def destroy
    Repositories::Courses.delete(id: params[:id])

    redirect_to courses_path, status: 303
  end

  def new
    @path_method = 'new_course_path'
    @possible_sessions = Repositories::SportSessions.find_with_traces(opts: {
      'id.not_in' => session_ids_from_courses,
      year: years, month: months, sport_type_id: sport_type_ids
    })
    @pre_selected = Repositories::SportSessions.find_by_id(id: params[:sport_session_id]) 
    @possible_sessions << @pre_selected unless @possible_sessions.map(&:id).include?(params[:sport_session_id])
  end

  def create_from_session
    UseCases::Course::AddFromSession.new(session: sport_session, name: params[:name]).run

    redirect_to courses_path
  end

  def add_all_matching_sessions
    UseCases::Course::AddAllMatchingSessions.new(course_id: params[:course_id]).run

    redirect_to course_path(id: params[:course_id])
  end

  private

  def duration_chart_data(assigned_sessions)
    assigned_sessions.reverse.each_with_object({}) do |sport_session, h|
      h[sport_session.start_time.strftime('%Y.%m.%d')] = (sport_session.duration / 1000.0 / 60).round(1)
    end
  end

  def stats_from_assigned(assigned_sessions)
    overall_distance = assigned_sessions.sum(&:distance)
    overall_duration = assigned_sessions.sum(&:duration)
    average_pace     = overall_duration / overall_distance.to_f * 1000 # ms / m * 1000 = ms/km
    {
      overall_distance: (overall_distance / 1000.0).round(2),
      overall_duration: format_ms(overall_duration),
      overall_elevation_gain: assigned_sessions.sum(&:elevation_gain),
      average_pace: format_ms(average_pace)
    }
  end

  def format_ms(millis)
    secs, = millis.divmod(1000) # divmod returns [quotient, modulus]
    mins, secs = secs.divmod(60)
    hours, mins = mins.divmod(60)
    hours = nil if hours.zero?

    [hours, mins, secs].compact.map { |e| e.to_s.rjust(2, '0') }.join ':'
  end

  def session_ids_from_courses
    Repositories::Courses.session_ids
  end

  def sport_session
    Repositories::SportSessions.find_by_id(id: params[:sport_session_id])
  end

  def assigned_sessions(course)
    return [] if course.session_ids.count.zero?

    sessions_repo.find_by_ids(
      ids: course.session_ids,
      sort: { attribute: 'start_time', direction: :desc }
    )
  end

  def matched_sessions(course)
    distance = course.distance
    sessions = sessions_repo.where(opts: {
      'distance.between' => [distance - 250, distance + 250],
      'id.not_in' => course.session_ids,
      'trace.exists' => true
    })
    sessions.each_with_object([]) do |session, ary|
      matcher = UseCases::Traces::Matcher.new(trace1: course.trace, trace2: session.trace)
      matcher.analyse
      ary << { session: session, match_rate: matcher.match_in_percent } if matcher.matching?
    end.compact.sort_by { |s| s[:session].start_time }.reverse
  end

  def sessions_repo
    Repositories::SportSessions
  end
end

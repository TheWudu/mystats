# frozen_string_literal: true

require 'repositories/sport_sessions'
require 'repositories/courses'

class CoursesController < ApplicationController
  def index
    @courses = Repositories::Courses.fetch
  end

  def show
    @course = Repositories::Courses.find(id: params[:id])
    @assigned_sessions = assigned_sessions(@course)
    @matching_sessions = matching_sessions(@course)
  end

  def destroy
    Repositories::Courses.delete(id: params[:id])

    redirect_to courses_path, status: 303 
  end

  def new
    @possible_sessions = Repositories::SportSessions.find_with_traces("id.not_in" => session_ids_from_courses)
  end

  def session_ids_from_courses
    Repositories::Courses.session_ids
  end

  def create_from_session
    UseCases::Course::AddFromSession.new(session: sport_session, name: params[:name]).run

    redirect_to courses_path
  end

  # private

  def sport_session
    Repositories::SportSessions.find_by_id(id: params[:session_id])
  end

  def assigned_sessions(course)
    return [] if course.session_ids.count.zero?

    sessions_repo.find_by_ids(ids: course.session_ids)
  end

  def matching_sessions(course)
    distance = course.distance
    sessions = sessions_repo.where(
      'distance.between' => [distance - 500, distance + 500],
      'id.not_in' => course.session_ids,
      'trace.exists' => true
    )
    sessions.each_with_object([]) do |session, ary|
      matcher = UseCases::Traces::Matcher.new(trace1: course.trace, trace2: session.trace)
      matcher.analyse
      ary << { session: session, match_rate: matcher.match_in_percent } if matcher.matching?
    end.compact
  end

  def sessions_repo
    Repositories::SportSessions
  end
end

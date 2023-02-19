# frozen_string_literal: true

require 'repositories/sport_sessions'
require 'repositories/courses'

class SessionController < ApplicationController
  def create
    unless course.session_ids.include?(params[:id])
      course.session_ids << params[:id]
      update_course
    end

    redirect_to course_path(id: course.id), status: 303
  end

  def destroy
    course.session_ids.delete(params[:id])

    update_course

    redirect_to course_path(id: course.id), status: 303
  end

  private

  def course
    @course ||= Repositories::Courses.find(id: params[:course_id])
  end

  def fix_session_ids
    existing_ids = Repositories::SportSessions.find_by_ids(ids:
                                                                course.session_ids).map(&:id)
    @course = course.new(session_ids: existing_ids)
  end

  def update_course
    fix_session_ids
    Repositories::Courses.update(course:)
  end
end

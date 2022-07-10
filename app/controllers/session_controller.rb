# frozen_string_literal: true

require 'repositories/sessions/mongo_db'
require 'repositories/courses/mongo_db'

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
    @course ||= Repositories::Courses::MongoDb.new.find(id: params[:course_id])
  end

  def update_course
    Repositories::Courses::MongoDb.new.update(course: course)
  end
end

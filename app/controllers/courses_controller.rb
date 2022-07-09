# frozen_string_literal: true

require 'repositories/sessions/mongo_db'
require 'repositories/courses/mongo_db'

class CoursesController < ApplicationController

  def index
    @courses = Repositories::Courses::MongoDb.new.fetch
ap @courses
  end

  def new_course
  end

  def create_from_session
    UseCases::Course::AddFromSession.new(session: sport_session, name: params[:name]).run 

    redirect_to courses_path
  end

  # private

  def sport_session
    Repositories::Sessions::MongoDb.new.find_by_id(id: params[:session_id])
  end

end

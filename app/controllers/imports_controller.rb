# frozen_string_literal: true

require 'repositories/sessions/mongo_db'
require 'sport_type'
require "parser/gpx"

class ImportsController < ApplicationController
  def index
  end

  def create
    data = params["input"].read
    @session = Parser::Gpx.new(data: data).parse
ap session
    
  end
end

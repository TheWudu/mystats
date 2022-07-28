# frozen_string_literal: true

require 'use_cases/session/import_gpx'

class ImportsController < ApplicationController
  def index; end

  def create
    data = params['input'].read

    use_case(data).run

    if use_case_errors
      flash[:warning] = use_case_errors
    else
      flash[:success] = "Successfully imported"
    end
    redirect_to sport_sessions_path
  end

  def use_case(data)
    @use_case ||= UseCases::Session::ImportGpx.new(data: data)
  end

  def use_case_errors
    return nil if @use_case.errors.empty?

    @use_case.errors.map(&:message).uniq.join("\n")
  end
end

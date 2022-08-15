# frozen_string_literal: true

require 'use_cases/session/import_gpx'

class ImportsController < ApplicationController
  def index; end

  def create
    data = File.open(params['input'].tempfile, 'r:UTF-8').read

    use_case = UseCases::Session::ImportGpx.new(data: data)
    use_case.run

    if use_case_errors(use_case)
      flash[:warning] = use_case_errors
    else
      flash[:success] = "Successfully imported #{use_case.count} sessions"
    end
    redirect_to sport_sessions_path
  end

  def use_case_errors(use_case)
    return nil if use_case.errors.empty?

    use_case.errors.map(&:message).uniq.join("\n")
  end
end

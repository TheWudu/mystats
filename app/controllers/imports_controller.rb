# frozen_string_literal: true

require 'use_cases/session/import_file'

class ImportsController < ApplicationController
  def index; end

  def create
    data = File.open(params['input'].tempfile, 'r:UTF-8').read
    extension = params['input'].original_filename.split(".").last

    use_case = UseCases::Session::ImportFile.new(data: data, type: extension) 
    use_case.run

    if (errors = use_case_errors(use_case))
      flash[:error] = errors
    elsif (warnings = use_case_warnings(use_case))
      flash[:warning] = warnings
    else
      flash[:success] = "Successfully imported #{use_case.count} sessions"
    end
    redirect_to sport_sessions_path
  end

  def use_case_warnings(use_case)
    return nil if use_case.warnings.empty?

    use_case.warnings.uniq.join(";\n")
  end

  def use_case_errors(use_case)
    return nil if use_case.errors.empty?

    use_case.errors.map(&:message).uniq.join(";\n")
  end
end

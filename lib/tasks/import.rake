# frozen_string_literal: true

require 'use_cases/session/import_runtastic_export'
require 'use_cases/session/import_gpx_folder'

namespace :import do
  desc 'Import a runtastic export'
  task :runtastic_export, [:path] do |_task, args|
    puts "Import runtastic export from #{args[:path]}"

    use_case = UseCases::Session::ImportRuntasticExport.new(path: args[:path])
    use_case.run
  end

  desc 'Import a folder with gpx files'
  task :gpx_folder, [:path] do |_task, args|
    puts "Import GPX folder from #{args[:path]}"

    use_case = UseCases::Session::ImportGpxFolder.new(path: args[:path])
    use_case.run
  end
end

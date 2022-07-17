# frozen_string_literal: true

require 'use_cases/session/import_runtastic_export'

namespace :import do
  desc 'This take does something useful!'

  task :runtastic_export, [:path] do |_task, args|
    puts "Import runtastic export from #{args[:path]}"

    use_case = UseCases::Session::ImportRuntasticExport.new(path: args[:path])
    use_case.run
  end
end

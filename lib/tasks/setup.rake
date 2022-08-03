# frozen_string_literal: true

require 'repositories/sport_sessions'

namespace :setup do
  desc 'Create indexes'
  task :create_indexes do |_task, _args|
    puts 'Create indexes for sport-sessions'

    Repositories::SportSessions.create_indexes
  end
end

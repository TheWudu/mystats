# frozen_string_literal: true

module Repositories
  module SportSessions
    extend Base

    METHODS = %w[fetch
                 find
                 find_by_id
                 find_by_ids
                 where
                 find_with_traces
                 exists?
                 insert].freeze

    create_methods(METHODS)
    setup_strategy(MongoDb)
  end
end

require_relative 'sport_sessions/mongo_db'

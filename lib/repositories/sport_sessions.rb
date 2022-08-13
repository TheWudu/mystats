# frozen_string_literal: true

require_relative 'base'
require_relative 'sport_sessions/mongo_db'

module Repositories
  module SportSessions
    extend Base

    METHODS = %w[fetch
                 find_by_id
                 find_by_ids
                 where
                 find_with_traces
                 exists?
                 insert
                 delete
                 create_indexes].freeze

    create_methods(METHODS)
    setup_strategy(MongoDb)
  end
end

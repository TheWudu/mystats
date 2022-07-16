# frozen_string_literal: true

module Repositories
  module Courses
    extend Base

    METHODS = %w[fetch
                 find
                 insert
                 update
                 session_ids
                 delete].freeze

    create_methods(METHODS)
    setup_strategy(MongoDb)
  end
end

require_relative 'courses/mongo_db'

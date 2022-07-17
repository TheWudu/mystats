# frozen_string_literal: true

require_relative "base"
require_relative 'cities/mongo_db'

module Repositories
  module Cities
    extend Base

    METHODS = %w[fetch
                 nearest
                 exist?
                 insert
                 create_geo_index
                 create_name_index].freeze

    create_methods(METHODS)
    setup_strategy(MongoDb)
  end
end


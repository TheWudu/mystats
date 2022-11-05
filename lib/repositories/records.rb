# frozen_string_literal: true

require_relative 'base'
require_relative 'records/mongo_db'

module Repositories
  module Records
    extend Base

    METHODS = %w[
      distance_per_month
      distance_per_week
      distance
      average_pace
      vam
    ].freeze

    create_methods(METHODS)
    setup_strategy(MongoDb)
  end
end

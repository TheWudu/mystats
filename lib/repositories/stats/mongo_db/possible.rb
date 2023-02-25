# frozen_string_literal: true

require_relative './base'

module Repositories
  module Stats
    module MongoDb
      class Possible < Base
        def initialize; end

        def years
          query = sessions.aggregate([
                                       { '$group' => { _id: '$year', cnt: { "$sum": 1 } } },
                                       { '$sort' => { _id: 1 } }
                                     ])
          query.map { |d| d['_id'] }
        end

        def sport_types
          query = sessions.aggregate([
                                       { '$group' => { _id: '$sport_type', cnt: { "$sum": 1 } } },
                                       { '$sort' => { cnt: -1 } }
                                     ])

          query.map { |d| d['_id'] }
        end
      end
    end
  end
end

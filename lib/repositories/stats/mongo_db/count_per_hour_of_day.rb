# frozen_string_literal: true

require_relative './base'

module Repositories
  module Stats
    module MongoDb
      class CountPerHourOfDay < Base
        def execute
          data = sessions.aggregate([
                                      { '$match' => matcher },
                                      { '$addFields' => { timezone: { '$ifNull' => ['$timezone', 'UTC'] } } },
                                      { '$addFields' => { hour: { '$hour' => { date:     '$start_time',
                                                                               timezone: '$timezone' } } } },
                                      { '$group' => { _id: '$hour', count: { '$sum' => 1 } } },
                                      { '$sort' => { _id: 1 } }
                                    ])

          data.each_with_object({}) do |d, h|
            h[d['_id']] = d['count']
          end
        end
      end
    end
  end
end

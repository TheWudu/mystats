# frozen_string_literal: true

require_relative './base'

module Repositories
  module Stats
    module MongoDb
      class DistanceBucket < Base
        def execute
          data = sessions.aggregate([
                                      { '$match' => matcher },
                                      { '$match' => { distance: { '$gt' => 0 } } },
                                      { '$bucket' => {
                                        groupBy:    '$distance',
                                        boundaries: [0, 5000, 7_500, 10_000, 15_000, 20_000, 100_000],
                                        default:    'no distance',
                                        output:     {
                                          total:        { '$sum' => 1 },
                                          avg_distance: { '$avg' => '$distance' },
                                          sum_distance: { '$sum' => '$distance' },
                                          sum_duration: { '$sum' => '$duration' }
                                        }
                                      } }
                                    ])

          data.each_with_object({}) do |d, h|
            h[d['_id']] = d['total']
          end
        end
      end
    end
  end
end

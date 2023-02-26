# frozen_string_literal: true

require_relative './base'

module Repositories
  module Stats
    module MongoDb
      class OverallAggregations < Base
        def execute(attr)
          data = sessions.aggregate([
                                      { '$match' => matcher },
                                      { '$group' => { _id:                    group_by,
                                                      overall_distance:       { '$sum' => '$distance' },
                                                      overall_duration:       { '$sum' => '$duration' },
                                                      overall_elevation_gain: { '$sum' => '$elevation_gain' },
                                                      overall_cnt:            { '$sum' => 1 } } },
                                      { '$addFields' => { overall_pace: { '$cond' => [
                                        { '$gt': ['$overall_distance', 0] },
                                        { '$divide' => ['$overall_duration', '$overall_distance'] },
                                        0
                                      ] } } },
                                      { '$sort' => { _id: 1 } }
                                    ]).to_a

          data.each_with_object({}) do |d, h|
            key = d['_id'].values.join('-')
            h[key] = d[attr]
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require_relative './base'

module Repositories
  module Stats
    module MongoDb
      class CountPerWeekday < Base
        def execute
          query = sessions.aggregate([
                                       { '$match' => matcher },
                                       { '$addFields' => { weekday: { '$dayOfWeek' => '$start_time' } } },
                                       { '$group' => { _id: '$weekday', cnt: { '$sum' => 1 } } },
                                       { '$sort' => { _id: 1 } }
                                     ])

          data = query.to_a.rotate(1)
          data.each_with_object({}) do |d, h|
            name = MONGO_WEEKDAY_IDX_TO_NAME[d['_id']]
            h[name] = d['cnt']
          end
        end

        MONGO_WEEKDAY_IDX_TO_NAME = {
          1 => 'Sunday',
          2 => 'Monday',
          3 => 'Tuesday',
          4 => 'Wednesday',
          5 => 'Thursday',
          6 => 'Friday',
          7 => 'Saturday'
        }.freeze
      end
    end
  end
end

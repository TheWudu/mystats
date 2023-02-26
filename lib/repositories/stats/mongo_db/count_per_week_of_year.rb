# frozen_string_literal: true

require_relative './base'

module Repositories
  module Stats
    module MongoDb
      class CountPerWeekOfYear < Base
        def execute
          docs = sessions.aggregate(cnt_per_week_of_year_query).to_a

          base_data_container = (0..52).each_with_object({}) do |week, h|
            h[week] = 0
          end

          # multiline data per year
          data = docs.each_with_object({}) do |d, h|
            h[d['_id']['year']] ||= base_data_container.dup
            h[d['_id']['year']][d['_id']['week']] = d['cnt']
          end

          data.map do |k, v|
            { name: k, data: v }
          end
        end

        private

        def cnt_per_week_of_year_query
          query = [{ '$match' => matcher },
                   { '$addFields' => { 'week'          => { '$isoWeek' => '$start_time' },
                                       'iso_week_year' => { "$isoWeekYear": '$start_time' } } }]
          query << { '$match' => { iso_week_year: { '$in' => years } } } if years && !years.empty?
          query << { '$group' => { _id: { year: '$iso_week_year', week: '$week' }, cnt: { '$sum' => 1 } } }
          query << { '$sort' => { _id: 1 } }
          query
        end
      end
    end
  end
end

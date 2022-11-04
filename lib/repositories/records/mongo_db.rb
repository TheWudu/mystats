# frozen_string_literal: true

require 'connections/mongo_db'
require 'sport_type'

module Repositories
  module Records
    class MongoDb
      attr_accessor :years, :sport_types, :group_by

      def distance_per_month(years:, sport_types:)
        q = [{ '$match' => matcher(years:, sport_types:) }]
        q << { '$group' => {
          _id:      { year: '$year', month: '$month' },
          distance: { '$sum' => '$distance' }
        } }
        q << { '$sort' => { distance: -1 } }
        q << { '$limit' => LIMIT }

        data = sessions.aggregate(q)
        data.each_with_object({}) do |doc, h|
          key = "#{doc['_id']['year']}-#{doc['_id']['month']}"
          h[key] = doc['distance'] / 1000.0
        end
      end

      def distance_per_week(years:, sport_types:)
        q = [{ '$match' => matcher(years:, sport_types:) }]
        q << { '$group' => {
          _id:      { year: '$year', week: { '$isoWeek' => '$start_time' } },
          distance: { '$sum' => '$distance' }
        } }
        q << { '$sort' => { distance: -1 } }
        q << { '$limit' => LIMIT }

        data = sessions.aggregate(q)
        data.each_with_object({}) do |doc, h|
          key = "#{doc['_id']['year']}-#{doc['_id']['week']}"
          h[key] = doc['distance'] / 1000.0
        end
      end

      def distance(years:, sport_types:)
        q = [{ '$match' => matcher(years:, sport_types:) }]
        q << { '$sort' => { distance: -1 } }
        q << { '$limit' => LIMIT }

        data = sessions.aggregate(q)
        data.each_with_object({}) do |doc, h|
          key = start_time_key(doc)
          h[key] = doc['distance'] / 1000.0
        end
      end

      def average_pace(years:, sport_types:)
        matcher_with_distance = matcher(years:, sport_types:).merge('distance' => { "$gt": 0 })

        q = [{ '$match' => matcher_with_distance }]
        q << { '$project' => {
          _id: 0, id: 1, start_time: 1, duration: 1, timezone: 1, distance: 1
        } }
        q << { '$addFields' => {
          average_pace: { '$divide' => ['$duration', '$distance'] }
        } }
        q << { '$sort' => { average_pace: 1 } }
        q << { '$limit' => LIMIT }

        data = sessions.aggregate(q)
        data.each_with_object({}) do |doc, h|
          key = start_time_key(doc)
          h[key] = (doc['average_pace'] / 60.0).round(2)
        end
      end

      private

      def matcher(years:, sport_types:)
        m = {}
        m.merge!(year: { '$in' => years }) if years && !years.empty?
        m.merge!(sport_type: { '$in' => sport_types }) if sport_types && !sport_types.empty?
        m
      end

      def start_time_key(doc)
        doc['start_time'].in_time_zone(doc['timezone']).strftime('%Y.%m.%d %H:%M:%S')
      end

      def sessions
        @sessions ||= Connections::MongoDb.connection[:sessions]
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

      LIMIT = 10
    end
  end
end

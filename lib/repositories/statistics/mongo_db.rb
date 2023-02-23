# frozen_string_literal: true

require 'connections/mongo_db'
require 'sport_type'

module Repositories
  module Statistics
    class MongoDb
      attr_accessor :years, :sport_types, :group_by

      def initialize(years:, sport_types:, group_by:)
        self.years = years
        self.sport_types = sport_types
        self.group_by = group_by
      end

      def possible_years
        query = sessions.aggregate([
                                     { '$group' => { _id: '$year', cnt: { "$sum": 1 } } },
                                     { '$sort' => { _id: 1 } }
                                   ])
        query.map { |d| d['_id'] }
      end

      def possible_sport_types
        query = sessions.aggregate([
                                     { '$group' => { _id: '$sport_type', cnt: { "$sum": 1 } } },
                                     { '$sort' => { cnt: -1 } }
                                   ])
        # query.each_with_object({}) do |d, h|
        #   h[d['_id']] = SportType.name_for(id: d['_id'])
        # end

        query.map { |d| d['_id'] }
      end

      def cnt_per_weekday_data
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

      def cnt_per_week_of_year
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

      def cnt_per_week_of_year_query
        query = [{ '$match' => matcher },
                 { '$addFields' => { 'week'          => { '$isoWeek' => '$start_time' },
                                     'iso_week_year' => { "$isoWeekYear": '$start_time' } } }]
        query << { '$match' => { iso_week_year: { '$in' => years } } } if years && !years.empty?
        query << { '$group' => { _id: { year: '$iso_week_year', week: '$week' }, cnt: { '$sum' => 1 } } }
        query << { '$sort' => { _id: 1 } }
        query
      end

      def data_per_year(attr)
        data = sessions.aggregate([
                                    { '$match' => matcher },
                                    { '$group' => { _id:                    group_by,
                                                    overall_distance:       { '$sum' => '$distance' },
                                                    overall_duration:       { '$sum' => '$duration' },
                                                    overall_elevation_gain: { '$sum' => '$elevation_gain' },
                                                    overall_cnt:            { '$sum' => 1 } } },
                                    { '$addFields' => { overall_pace: { '$cond' => [
                                      { '$gt': ['$overall_distance',
                                                0] }, { '$divide' => ['$overall_duration', '$overall_distance'] }, 0
                                    ] } } },
                                    { '$sort' => { _id: 1 } }
                                  ]).to_a
        data.each_with_object({}) do |d, h|
          key = d['_id'].values.join('-')
          h[key] = d[attr]
        end
      end

      def distance_bucket_data
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

      def hour_per_day_data
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

      def yoy(grouping = 'week')
        group = if grouping == 'week'
                  { year: '$iso_week_year', week: '$iso_week' }
                else
                  '$date'
                end
        data = sessions.aggregate([
                                    { '$match' => matcher },
                                    { '$addFields' => {
                                      timezone: { '$ifNull' => ['$timezone', 'UTC'] },
                                       date: { '$dateToString' => { date:     '$start_time',
                                                                    timezone: '$timezone',
                                                                    format:   '%Y-%m-%d' } },
                                      'iso_week'      => { '$isoWeek' => '$start_time' },
                                      'iso_week_year' => { "$isoWeekYear": '$start_time' }
                                    } },
                                    { '$group' => { _id:      group,
                                                    distance: { '$sum' => '$distance' } } },
                                    { '$sort' => { _id: 1 } }
                                  ])

        result = []
        years.each do |year|
          result << { name: year, data: fill_days(year, grouping, data) }
        end

        result
      end

      def fill_days(year, grouping, data)
        year_sum = 0

        r = {}
        if grouping == 'day'
          (Date.parse("#{year}-01-01")..Date.parse("#{year}-12-31")).each do |day|
            r["#{day.day}.#{day.month}."] = 0
          end

          data.each do |d|
            date = Date.parse(d['_id'])
            next if date.year != year

            r[date.strftime('%-d.%-m.')] = d['distance'] / 1000.0
          end
        else
          # (Date.parse("#{year}-01-01").cweek..Date.parse("#{year}-12-31").cweek).each do |week|
          53.times do |week|
            r[week] = 0
          end

          data.each do |d|
            # date = Date.parse(d['_id'])
            # next if date.year != year
            next if d.dig('_id', 'year') != year

            r[d.dig('_id', 'week')] = d['distance'] / 1000.0
          end
        end

        r.each do |k, v|
          year_sum += v
          r[k] = year_sum.round(2)
        end
        r
      end

      private

      def matcher
        m = {}
        m.merge!(year: { '$in' => years }) if years && !years.empty?
        m.merge!(sport_type: { '$in' => sport_types }) if sport_types && !sport_types.empty?
        m
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
    end
  end
end

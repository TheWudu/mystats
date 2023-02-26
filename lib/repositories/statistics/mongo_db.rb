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
    end
  end
end

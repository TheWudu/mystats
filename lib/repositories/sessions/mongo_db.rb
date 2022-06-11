# frozen_string_literal: true

require 'connections/mongo_db'

module Repositories
  module Sessions
    class MongoDb
      attr_accessor :years, :months, :sport_type_ids

      def initialize(years:, months:, sport_type_ids:)
        self.years = years
        self.months = months
        self.sport_type_ids = sport_type_ids
      end

      def fetch
        sessions.find(matcher).sort({ start_time: -1 }).to_a
      end

      private

      def matcher # rubocop:disable Metrics/AbcSize
        m = {}
        m.merge!(year: { '$in' => years }) if years && !years.empty?
        m.merge!(month: { '$in' => months }) if months && !months.empty?
        m.merge!(sport_type_id: { '$in' => sport_type_ids }) if sport_type_ids && !sport_type_ids.empty?
        m
      end

      def sessions
        @sessions ||= Connections::MongoDb.connection[:sessions]
      end
    end
  end
end

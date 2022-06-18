# frozen_string_literal: true

require 'connections/mongo_db'

module Repositories
  module Sessions
    class MongoDb
      def fetch(years:, months:, sport_type_ids:)
        matcher = build_matcher(years: years, months: months, sport_type_ids: sport_type_ids)

        sessions.find(matcher).sort({ start_time: -1 }).to_a
      end
        
      def find(start_time: , sport_type_id: )
        sessions.find({ start_time: start_time, sport_type_id: sport_type_id }).first
      end
      
      def exists?(start_time: , sport_type_id: )
        sessions.count({ start_time: start_time, sport_type_id: sport_type_id }) > 0 
      end

      def insert(session:)
        sessions.insert_one(prepare_for_write(session))
      end

      private

      def prepare_for_write(session)
        session.merge(
          year:  session[:start_time].year,
          month: session[:start_time].month
        )
      end

      def build_matcher(years: nil, months: nil, sport_type_ids: nil) # rubocop:disable Metrics/AbcSize
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

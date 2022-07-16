# frozen_string_literal: true

require 'connections/mongo_db'

module Repositories
  module SportSessions
    class MongoDb
      def fetch(years:, months:, sport_type_ids:, text: nil)
        matcher = build_matcher(years: years, months: months, sport_type_ids: sport_type_ids)
        matcher.merge!(text_filter(text)) unless text.blank?

        collection.find(matcher).sort({ start_time: -1 }).map do |doc|
          to_model(doc)
        end
      end

      def find(start_time:, sport_type_id:)
        sessions = collection.find({ start_time: start_time, sport_type_id: sport_type_id })
        return unless sessions.count == 1

        to_model(sessions.first)
      end

      def find_by_id(id:)
        sessions = collection.find({ id: id })
        return nil unless sessions.count == 1

        to_model(sessions.first)
      end

      def find_by_ids(ids:)
        sessions = collection.find({ id: { '$in' => ids } })
        sessions.map do |session|
          to_model(session)
        end
      end

      def where(opts = {})
        query = {}
        if opts['distance.between']
          query.merge!({ distance: { '$gte' => opts['distance.between'].first,
                                     '$lte' => opts['distance.between'].second } })
        end
        query.merge!({ id: { '$nin' => opts['id.not_in'] } }) if opts['id.not_in']
        query.merge!({ trace: { '$exists' => opts['trace.exists'] } }) if opts['trace.exists']
        collection.find(query).map do |session|
          to_model(session)
        end
      end

      def find_with_traces(opts = {})
        query = { trace: { '$exists' => true } }
        query.merge!(id: { '$nin' => opts['id.not_in'] }) if opts['id.not_in']
        collection.find(query)
                  .sort({ start_time: -1 }).map do |session|
          to_model(session)
        end
      end

      def exists?(start_time:, sport_type_id:)
        collection.count({ start_time: start_time, sport_type_id: sport_type_id }).positive?
      end

      def insert(session:)
        collection.insert_one(prepare_for_write(session))
      end

      private

      def to_model(doc)
        Models::SportSession.new(doc.except('_id'))
      end

      def text_filter(text)
        { '$text' =>
          {
            '$search' => text,
            # "$language" => <string>,
            '$caseSensitive' => false
            # "$diacriticSensitive" => <boolean>
          } }
      end

      def prepare_for_write(session)
        session.merge(
          year: session[:start_time].year,
          month: session[:start_time].month
        )
      end

      def build_matcher(years: nil, months: nil, sport_type_ids: nil)
        m = {}
        m.merge!(year: { '$in' => years }) if years && !years.empty?
        m.merge!(month: { '$in' => months }) if months && !months.empty?
        m.merge!(sport_type_id: { '$in' => sport_type_ids }) if sport_type_ids && !sport_type_ids.empty?
        m
      end

      def collection
        @collection ||= Connections::MongoDb.connection[:sessions]
      end
    end
  end
end

# frozen_string_literal: true

require 'connections/mongo_db'

module Repositories
  module SportSessions
    class MongoDb
      def fetch(years:, months:, sport_types:, text: nil)
        matcher = build_matcher(years:, months:, sport_types:)
        matcher.merge!(text_filter(text)) unless text.blank?

        collection.find(matcher).sort({ start_time: -1 }).map do |doc|
          to_model(doc)
        end
      end

      def find_by_id(id:)
        sessions = find_by_ids(ids: [id])
        return nil unless sessions.count == 1

        sessions.first
      end

      def find_by_ids(ids:, sort: nil)
        view = collection.find({ id: { '$in' => ids } })
        view = view.sort(sort_option(sort)) if sort
        view.map do |session|
          to_model(session)
        end
      end

      def delete(id:)
        resp = collection.delete_one(id:)
        resp.n == 1
      end

      def sort_option(sort)
        { sort[:attribute].to_s => sort[:direction] == :asc ? 1 : -1 }
      end

      def where(opts: {})
        Where.new.execute(opts)
      end

      def find_with_traces(id__not_in: nil, year: nil, month: nil, sport_type: nil)
        opts = {
          'trace.exists' => true,
          'id.not_in'    => id__not_in,
          'year'         => year,
          'month'        => month,
          'sport_type'   => sport_type
        }
        Where.new.execute(opts)
      end

      def exists?(start_time:, sport_type:)
        !!find_by_start_time_and_sport_type(start_time:, sport_type:)
      end

      def insert(session_hash:)
        resp = collection.insert_one(prepare_for_write(session_hash))
        resp.n == 1
      end

      def find_by_start_time_and_sport_type(start_time:, sport_type:)
        collection.find({ year:       start_time.year,
                          month:      start_time.month,
                          start_time: {
                            '$gte' => (start_time - 1.minute),
                            '$lte' => (start_time + 1.minute)
                          },
                          sport_type: }).first
      end

      def update(session_hash:)
        start_time = session_hash[:start_time]
        sport_type = session_hash[:sport_type]
        doc = find_by_start_time_and_sport_type(start_time:, sport_type:)
        return false unless doc

        resp = collection.find({ _id: doc['_id'] }).update_one({ '$set' => prepare_for_update(doc['id'],
                                                                                              session_hash) })
        resp.n == 1
      end

      def create_indexes
        Indexes.new.create
      end

      private

      IGNORE_DB_KEYS = %w[_id sport_type_id].freeze

      def to_model(doc)
        Models::SportSession.new(doc.except(*IGNORE_DB_KEYS).symbolize_keys)
      end

      def text_filter(text)
        { '$text' =>
                     {
                       '$search'        => text,
                       # "$language" => <string>,
                       '$caseSensitive' => false
                       # "$diacriticSensitive" => <boolean>
                     } }
      end

      PROTECTED_ATTRIBUTES = %i[
        _id id
      ].freeze

      def prepare_for_update(_id, session_hash)
        prepare_for_write(session_hash).except(*PROTECTED_ATTRIBUTES)
      end

      def prepare_for_write(session_hash)
        session_hash.merge(
          year:  session_hash[:start_time].year,
          month: session_hash[:start_time].month
        ).compact
      rescue NoMethodError
        raise ArgumentError, 'missing start_time'
      end

      def build_matcher(years: nil, months: nil, sport_types: nil)
        m = {}
        m.merge!(year: { '$in' => years }) if years && !years.empty?
        m.merge!(month: { '$in' => months }) if months && !months.empty?
        m.merge!(sport_type: { '$in' => sport_types }) if sport_types && !sport_types.empty?
        m
      end

      def collection
        @collection ||= Connections::MongoDb.connection[:sessions]
      end
    end
  end
end

require_relative 'indexes'

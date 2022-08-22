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
        resp = collection.delete_one(id: id)
        resp.n == 1
      end

      def sort_option(sort)
        { sort[:attribute].to_s => sort[:direction] == :asc ? 1 : -1 }
      end

      def where(opts: {})
        Where.new.execute(opts)
      end

      def find_with_traces(id__not_in: nil, year: nil, month: nil, sport_type_id: nil)
        opts = {
          'trace.exists'  => true,
          'id.not_in'     => id__not_in,
          'year'          => year,
          'month'         => month,
          'sport_type_id' => sport_type_id
        }
        Where.new.execute(opts)
      end

      def exists?(start_time:, sport_type_id:)
        collection.count({ year:          start_time.year,
                           month:         start_time.month,
                           start_time:    {
                             '$gte' => (start_time - 1.minute),
                             '$lte' => (start_time + 1.minute)
                           },
                           sport_type_id: sport_type_id }).positive?
      end

      def insert(session:)
        resp = collection.insert_one(prepare_for_write(session))
        resp.n == 1
      end

      def create_indexes
        Indexes.new.create
      end

      private

      def to_model(doc)
        Models::SportSession.new(doc.except('_id').symbolize_keys)
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

      def prepare_for_write(session)
        session.merge(
          year:  session[:start_time].year,
          month: session[:start_time].month
        ).compact
      rescue NoMethodError => e
        raise ArgumentError, 'missing start_time'
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

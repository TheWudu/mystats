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

      # def find(start_time:, sport_type_id:)
      #   sessions = collection.find({ year: start_time.year, month: start_time.month,
      #     start_time: start_time, sport_type_id: sport_type_id
      #   })
      #   return unless sessions.count == 1

      #   to_model(sessions.first)
      # end

      def find_by_id(id:)
        sessions = collection.find({ id: id })
        return nil unless sessions.count == 1

        to_model(sessions.first)
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
        query.merge!(year: { '$in' => opts[:year] }) unless opts[:year].blank?
        query.merge!(month: { '$in' => opts[:month] }) unless opts[:month].blank?
        query.merge!(sport_type_id: { '$in' => opts[:sport_type_id] }) unless opts[:sport_type_id].blank?
        collection.find(query)
                  .sort({ start_time: -1 }).map do |session|
          to_model(session)
        end
      end

      def exists?(start_time:, sport_type_id:)
        collection.count({ year: start_time.year,
                           month: start_time.month,
                           start_time: {
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
        create_year_month_index
        create_id_distance_index
        create_notes_text_index
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
        ).compact
      rescue NoMethodError => e
        raise ArgumentError.new("missing start_time") 
      end

      def build_matcher(years: nil, months: nil, sport_type_ids: nil)
        m = {}
        m.merge!(year: { '$in' => years }) if years && !years.empty?
        m.merge!(month: { '$in' => months }) if months && !months.empty?
        m.merge!(sport_type_id: { '$in' => sport_type_ids }) if sport_type_ids && !sport_type_ids.empty?
        m
      end

      def create_year_month_index
        name = 'year_month_sport_type_id_start_time'
        index = { year: 1, month: 1, sport_type_id: 1, start_time: 1 }

        create_index_if_not_exist(name, index)
      end

      def create_id_distance_index
        name  = 'id_distance'
        index = { id: 1, distance: 1 }

        create_index_if_not_exist(name, index)
      end

      def create_notes_text_index
        name  = 'notes'
        index = { notes: 'text' }

        create_index_if_not_exist(name, index)
      end

      def create_index_if_not_exist(name, index)
        return if find_index(name)

        puts "Create: #{name}, #{index}"

        options = { name: name }

        Mongo::Index::View.new(collection).create_one(index, options)
      end

      def find_index(name)
        collection.indexes.find { |index| index['name'] == name }
      rescue StandardError
        nil
      end

      def collection
        @collection ||= Connections::MongoDb.connection[:sessions]
      end
    end
  end
end

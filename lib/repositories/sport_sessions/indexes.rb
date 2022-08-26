# frozen_string_literal: true

require_relative "mongo_db"

module Repositories
  module SportSessions
    class Indexes < MongoDb
      def create
        create_year_month_index
        create_id_distance_index
        create_notes_text_index
      end

      def create_year_month_index
        name = 'year_month_sport_type_start_time'
        index = { year: 1, month: 1, sport_type: 1, start_time: 1 }

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
    end
  end
end

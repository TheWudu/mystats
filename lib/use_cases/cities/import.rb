# frozen_string_literal: true

require 'parser/gpx'

module UseCases
  module Cities
    class Import
      attr_reader :cities

      def initialize(cities:)
        @cities = cities
      end

      def run
        create_indexes

        cities.each do |city|
          next if exist?(city)

          store(city)
        end
      end

      private

      def exist?(city)
        repo.exist?(city[:name])
      end

      def store(city)
        repo.insert(city)
      end

      def create_indexes
        repo.create_geo_index
        repo.create_name_index
      end

      def repo
        Repositories::Cities
      end
    end
  end
end

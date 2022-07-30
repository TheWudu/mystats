# frozen_string_literal: true

# require 'connections/mongo_db'
require_relative '../../connections/mongo_db'

module Repositories
  module Cities
    class MongoDb
      MAX_DISTANCE = 10_000

      attr_accessor :years, :months, :sport_type_ids

      def fetch(name: nil, latitude: nil, longitude: nil, timezone: nil)
        matcher = {}
        matcher.merge!(geo_matcher(latitude, longitude, 50_000)) unless latitude.blank? && longitude.blank?
        matcher.merge!(name: /#{name}/) unless name.blank?
        matcher.merge!(timezone: timezone) unless timezone.blank?

        cities.find(matcher).limit(500).to_a
      end

      def nearest(lat:, lng:)
        cities.find(geo_matcher(lat, lng)).limit(1).first
      end

      def exist?(name:)
        cities.find({ name: name }).limit(1).first
      end

      def insert(city:)
        cities.insert_one(prepare(city))
      end

      def create_geo_index
        name = 'geolocation'
        return if find_index(name)

        index = { location: '2dsphere' }
        options = { name: name }

        Mongo::Index::View.new(cities).create_one(index, options)
      end

      def create_name_index
        name = 'geoname'
        return if find_index(name)

        index = { name: 1 }
        options = { name: name }

        Mongo::Index::View.new(cities).create_one(index, options)
      end

      def find_index(name)
        cities.indexes.find { |index| index['name'] == name }
      rescue StandardError
        nil
      end

      private

      def prepare(city)
        {
          name: city[:name],
          timezone: city[:timezone],
          location: {
            type: 'Point',
            coordinates: [city[:longitude], city[:latitude]]
          }
        }
      end

      def geo_matcher(lat, lng, max_dist = MAX_DISTANCE)
        {
          'location' => {
            '$geoNear' => {
              '$geometry' => { "type": 'Point', coordinates: [lng.to_f, lat.to_f] },
              '$maxDistance' => max_dist
            }
          }
        }
      end

      def cities
        @cities ||= Connections::MongoDb.connection[:cities]
      end
    end
  end
end

# frozen_string_literal: true


#require 'connections/mongo_db'
require_relative "../../connections/mongo_db"

module Repositories
  module Cities
    class MongoDb
      attr_accessor :years, :months, :sport_type_ids

      def nearest(lat:, lng:)
        cities.find( matcher(lat, lng) ).limit(1).first
      end

      private

      def matcher(lat, lng)
        { 
          "location" => { 
            "$geoNear" => { 
              "$geometry" => { "type": "Point", coordinates: [lng, lat] } 
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

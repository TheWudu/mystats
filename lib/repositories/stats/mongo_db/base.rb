# frozen_string_literal: true

module Repositories
  module Stats
    module MongoDb
      class Base
        attr_accessor :years, :sport_types, :group_by

        def initialize(years:, sport_types:, group_by:)
          self.years = years
          self.sport_types = sport_types
          self.group_by = group_by
        end

        private

        def matcher
          m = {}
          m.merge!(year: { '$in' => years }) if years && !years.empty?
          m.merge!(sport_type: { '$in' => sport_types }) if sport_types && !sport_types.empty?
          m
        end

        def sessions
          @sessions ||= Connections::MongoDb.connection[:sessions]
        end
      end
    end
  end
end

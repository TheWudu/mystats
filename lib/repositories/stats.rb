# frozen_string_literal: true

require_relative 'base'
require_relative 'stats/mongo_db/year_over_year'
require_relative 'stats/mongo_db/possible'

module Repositories
  module Stats
    def self.year_over_year(years:, sport_types:, group_by:)
      Stats::MongoDb::YearOverYear.new(
        years:,
        sport_types:,
        group_by:
      )
                                  .execute
    end

    def self.possible_years
      Stats::MongoDb::Possible.new.years
    end

    def self.possible_sport_types
      Stats::MongoDb::Possible.new.sport_types
    end
  end
end

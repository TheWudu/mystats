# frozen_string_literal: true

require_relative 'base'
require_relative 'stats/mongo_db/year_over_year'
require_relative 'stats/mongo_db/count_per_weekday'
require_relative 'stats/mongo_db/possible'
require_relative 'stats/mongo_db/distance_bucket'
require_relative 'stats/mongo_db/count_per_hour_of_day'
require_relative 'stats/mongo_db/count_per_week_of_year'
require_relative 'stats/mongo_db/overall_aggregations'

module Repositories
  module Stats
    def self.possible_years
      Stats::MongoDb::Possible.new.years
    end

    def self.possible_sport_types
      Stats::MongoDb::Possible.new.sport_types
    end

    def self.year_over_year(years:, sport_types:, group_by:)
      Stats::MongoDb::YearOverYear.new(
        years:,
        sport_types:,
        group_by:
      ).execute
    end

    def self.count_per_weekday(years:, sport_types:, group_by:)
      Stats::MongoDb::CountPerWeekday.new(
        years:,
        sport_types:,
        group_by:
      ).execute
    end

    def self.distance_bucket(years:, sport_types:, group_by:)
      Stats::MongoDb::DistanceBucket.new(
        years:,
        sport_types:,
        group_by:
      ).execute
    end

    def self.count_per_hour_of_day(years:, sport_types:, group_by:)
      Stats::MongoDb::CountPerHourOfDay.new(
        years:,
        sport_types:,
        group_by:
      ).execute
    end

    def self.count_per_week_of_year(years:, sport_types:, group_by:)
      Stats::MongoDb::CountPerWeekOfYear.new(
        years:,
        sport_types:,
        group_by:
      ).execute
    end

    def self.overall_aggregations(years:, sport_types:, group_by:, attribute:)
      Stats::MongoDb::OverallAggregations.new(
        years:,
        sport_types:,
        group_by:
      ).execute(attribute)
    end
  end
end

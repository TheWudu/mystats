# frozen_string_literal: true

require_relative 'base'
require_relative 'stats/mongo_db/year_over_year'

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
  end
end

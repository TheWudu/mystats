# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Stats do
  %w[
    possible_years
    possible_sport_types
    year_over_year
    count_per_weekday
    distance_bucket
    count_per_weekday
    count_per_hour_of_day
    count_per_week_of_year
    overall_aggregations
  ].each do |method|
    it "responds to #{method}" do
      expect(described_class.respond_to?(method)).to be_truthy
    end
  end
end

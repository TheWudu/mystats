# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Statistics::MongoDb do
  let(:instance) do
    described_class.new(
      years:       [2022],
      sport_types: %w[running cycling],
      group_by:    %i[year month]
    )
  end

  %w[cnt_per_week_of_year
     data_per_year
     hour_per_day_data].each do |method|
    it "responds to #{method}" do
      expect(instance.respond_to?(method)).to be_truthy
    end
  end
end

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

  %w[data_per_year].each do |method|
    it "responds to #{method}" do
      expect(instance.respond_to?(method)).to be_truthy
    end
  end
end

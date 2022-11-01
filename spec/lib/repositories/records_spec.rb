# frozen_string_literal: true

require 'rails_helper'
require 'repositories/records'

describe Repositories::Records do
  %w[
    distance
    distance_per_week
    distance_per_month
    average_pace
  ].each do |method|
    it "responds to #{method}" do
      expect(described_class.respond_to?(method)).to be_truthy
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'repositories/sport_sessions'

describe Repositories::SportSessions do
  %w[fetch
     find_by_id
     find_by_ids
     delete
     where
     find_with_traces
     exists?
     insert].each do |method|
    it "responds to #{method}" do
      expect(described_class.respond_to?(method)).to be_truthy
    end
  end
end

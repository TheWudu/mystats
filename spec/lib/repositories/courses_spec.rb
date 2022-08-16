# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Courses do
  %w[fetch
     find
     find_by_session_id
     insert
     update
     delete
     session_ids].each do |method|
    it "responds to #{method}" do
      expect(described_class.respond_to?(method)).to be_truthy
    end
  end
end

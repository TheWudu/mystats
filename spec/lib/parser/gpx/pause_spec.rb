# frozen_string_literal: true

require 'rails_helper'

describe Parser::Gpx do
  let(:data) { File.read(input_file) }

  let(:parser) { described_class.new(data:) }
  subject { parser.parse }

  context 'with running session' do
    let(:input_file) { 'spec/fixtures/traces/running_8km.gpx' }

    # has a pause of 02:29 (149 s) regarding runtastic
    # it { expect(subject.first[:pause]).to eq(149000) }
    it { expect(subject.first[:pause]).to eq(110_000) }
  end

  context 'with a hiking session' do
    let(:input_file) { 'spec/fixtures/traces/hiking_20220830_gradlspitz.gpx' }

    # has a pause of 17:58 (1078 s) regarding runtastic
    it { expect(subject.first[:pause]).to eq(1_105_000) }
  end

  context 'with swimming session' do
    let(:input_file) { 'spec/fixtures/traces/swimming_short.gpx' }

    it { expect(subject.first[:pause]).to eq(0) }
  end
end

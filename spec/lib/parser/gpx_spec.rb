# frozen_string_literal: true

require 'rails_helper'

describe Parser::Gpx do
  let(:input_file) { 'spec/fixtures/traces/running_8km.gpx' }
  let(:data) { File.read(input_file) }

  subject { described_class.new(data:).parse }

  let(:expected_data) do
    {
      id:                         anything,
      distance:                   8732,
      duration:                   2_961_000,
      duration_up:                1_821_000,
      elevation_gain:             169,
      elevation_loss:             167,
      end_time:                   Time.parse('2022-08-13T06:18:01Z'),
      notes:                      'Samstag Morgenlauf',
      pause:                      119_000,
      sport_type:                 'running',
      start_time:                 Time.parse('2022-08-13T05:26:41Z'),
      start_time_timezone_offset: 0,
      timezone:                   'UTC',
      heart_rate_avg:             145,
      heart_rate_max:             179,
      trace:                      anything
    }
  end

  it { expect(subject.first).to include(expected_data) }

  context 'when sport-type is not given' do
    let(:input_file) { 'spec/fixtures/traces/runtastic_with_gpxtpx.gpx' }
    let(:data) { File.read(input_file) }

    subject { described_class.new(data:).parse }

    it 'sets default value' do
      expect(subject.first[:sport_type]).to eq(SportType.default)
    end
  end
end

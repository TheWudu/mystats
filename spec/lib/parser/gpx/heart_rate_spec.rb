# frozen_string_literal: true

require 'rails_helper'

describe Parser::Gpx do
  let(:input_file) { 'spec/fixtures/traces/running_8km.gpx' }
  let(:data) { File.read(input_file) }

  subject { described_class.new(data: data).parse }

  let(:trace) { subject.first[:trace] }
  let(:expected_data) do
    {
      id:                         anything,
      distance:                   8743,
      duration:                   2_913_000,
      elevation_gain:             170,
      elevation_loss:             167,
      end_time:                   Time.parse('2022-08-13T06:18:01Z'),
      notes:                      'Samstag Morgenlauf',
      pause:                      167_000,
      sport_type:                 'running',
      start_time:                 Time.parse('2022-08-13T05:26:41Z'),
      start_time_timezone_offset: 0,
      timezone:                   'UTC',
      heart_rate_avg:             145,
      heart_rate_max:             179,
      trace:                      anything
    }
  end

  it 'has correct hr values' do
    expect(trace.first).to include(hr: 66)
    expect(trace.last).to include(hr: 173)
  end
end
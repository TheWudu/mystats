# frozen_string_literal: true

require 'rails_helper'

describe Parser::Gpx do
  let(:input_file) { 'spec/fixtures/traces/running_8km.gpx' }
  let(:data) { File.read(input_file) }

  subject { described_class.new(data: data).parse }

  let(:expected_data) do
    {
      id:                         anything,
      distance:                   8732,
      duration:                   2_970_000,
      elevation_gain:             169,
      elevation_loss:             167,
      end_time:                   Time.parse('2022-08-13T06:18:01Z'),
      notes:                      'Samstag Morgenlauf',
      pause:                      110_000,
      sport_type:                 'running',
      start_time:                 Time.parse('2022-08-13T05:26:41Z'),
      start_time_timezone_offset: 0,
      timezone:                   'UTC',
      trace:                      anything
    }
  end

  it { expect(subject.first).to include(expected_data) }
end

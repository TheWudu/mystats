# frozen_string_literal: true

require 'rails_helper'

describe Parser::Gpx do
  context 'when file uses ns3 extensions' do
    let(:input_file) { 'spec/fixtures/traces/running_8km.gpx' }
    let(:data) { File.read(input_file) }

    subject { described_class.new(data:).parse }

    let(:trace) { subject.first[:trace] }
    let(:expected_data) do
      {
        id:                         anything,
        distance:                   8732,
        duration:                   2_961_000,
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

    it 'has correct hr values' do
      expect(trace.first).to include(hr: 66)
      expect(trace.last).to include(hr: 173)

      expect(subject.first).to include(expected_data)
    end
  end

  context 'when file uses gpxtpx extensions' do
    let(:input_file) { 'spec/fixtures/traces/runtastic_with_gpxtpx.gpx' }
    let(:data) { File.read(input_file) }

    subject { described_class.new(data:).parse }

    let(:trace) { subject.first[:trace] }
    let(:expected_data) do
      {
        id:                         anything,
        distance:                   7228,
        duration:                   2_416_000,
        elevation_gain:             152,
        elevation_loss:             151,
        end_time:                   Time.parse('2022-09-06T05:57:35Z'),
        notes:                      'runtastic_20220906_0516',
        pause:                      47_000,
        sport_type:                 'unknown',
        start_time:                 Time.parse('2022-09-06T05:16:32Z'),
        start_time_timezone_offset: 0,
        timezone:                   'UTC',
        heart_rate_avg:             147,
        heart_rate_max:             175,
        trace:                      anything
      }
    end

    it 'has correct hr values' do
      expect(trace.first).to include(hr: 79)
      expect(trace.last).to include(hr: 166)

      expect(subject.first).to include(expected_data)
    end
  end
end

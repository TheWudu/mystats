# frozen_string_literal: true

require 'rails_helper'

describe Parser::RuntasticJson do
  let(:parser) { described_class.new(json_data: json_data, gpx_data: gpx_data) }

  subject { parser.parse }

  context 'with yoga session without trace as input' do
    let(:json_input_file) { 'spec/fixtures/runtastic/yoga.json' }
    let(:json_data) { File.read(json_input_file) }

    let(:gpx_data) { nil }

    let(:expected_data) do
      {
        id:                         anything,
        distance:                   0,
        duration:                   805_000,
        end_time:                   Time.parse('2022-07-03T15:53:57Z'),
        notes:                      'A bit hard, or was it to much barbecue? Yoga plan W2D3 ',
        pause:                      38_000,
        sport_type:                 'training',
        start_time:                 Time.parse('2022-07-03T15:39:50Z'),
        start_time_timezone_offset: 7200,
        timezone:                   'Europe/Vienna',
        trace:                      []
      }
    end

    it { expect(subject).to include(expected_data) }
  end

  context 'with running session without gpx-trace as input' do
    let(:json_input_file) { 'spec/fixtures/runtastic/running_8km.json' }
    let(:json_data) { File.read(json_input_file) }

    let(:gpx_data) { nil }

    let(:expected_data) do
      {
        id:                         anything,
        distance:                   8749,
        duration:                   2_905_000,
        elevation_gain:             127,
        elevation_loss:             125,
        end_time:                   Time.parse('2022-07-02T06:01:28Z'),
        notes:                      'Morning run starting below the high fog',
        pause:                      123_510,
        sport_type:                 'running',
        start_time:                 Time.parse('2022-07-02T05:11:00Z'),
        start_time_timezone_offset: 7200,
        timezone:                   'Europe/Vienna',
        trace:                      []
      }
    end

    it { expect(subject).to include(expected_data) }
  end

  context 'when running session with trace as input' do
    let(:json_input_file) { 'spec/fixtures/runtastic/running_8km.json' }
    let(:json_data) { File.read(json_input_file) }

    let(:gpx_input_file) { 'spec/fixtures/runtastic/running_8km.gpx' }
    let(:gpx_data) { File.read(gpx_input_file) }

    let(:expected_data) do
      {
        id:                         anything,
        distance:                   8749,
        duration:                   2_905_000,
        elevation_gain:             127,
        elevation_loss:             125,
        end_time:                   Time.parse('2022-07-02T06:01:28Z'),
        notes:                      'Morning run starting below the high fog',
        pause:                      123_510,
        sport_type:                 'running',
        start_time:                 Time.parse('2022-07-02T05:11:00Z'),
        start_time_timezone_offset: 7200,
        timezone:                   'UTC',
        trace:                      anything
      }
    end

    it { expect(subject).to include(expected_data) }
    it 'adds warning about not imported cities' do
      subject
      expect(parser.warnings).to eq(['Cities not imported, timezone might be wrong'])
    end
  end
end

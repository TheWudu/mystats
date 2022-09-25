# frozen_string_literal: true

require 'rails_helper'

describe Parser::Fit do
  let(:input_file) { 'spec/fixtures/traces/running_9653966916.fit' }
  let(:data) { File.read(input_file) }

  subject { described_class.new(data: data).parse }

  let(:expected_data) do
    {
      id:                         anything,
      distance:                   6741,
      duration:                   2_391_703,
      elevation_gain:             66,
      elevation_loss:             66,
      end_time:                   Time.parse('2022-09-22T10:42:02Z'),
      notes:                      'Lunchrun mit Gustavo und Sebastian',
      pause:                      297,
      sport_type:                 'running',
      start_time:                 Time.parse('2022-09-22T10:02:11Z'),
      start_time_timezone_offset: 0,
      timezone:                   'UTC',
      heart_rate_avg:             156,
      heart_rate_max:             176,
      # trace:                      anything
    }
  end

  it { expect(subject.first).to include(expected_data) }

  context "when file contains pause" do 
    let(:input_file) { 'spec/fixtures/traces/running_with_pause_9611115001.fit' }

    let(:expected_data) do
      {
        id:                         anything,
        distance:                   6671,
        duration:                   2_156_716,
        elevation_gain:             135,
        elevation_loss:             136,
        end_time:                   Time.parse('2022-09-15T13:51:23Z'),
        notes:                      'Lunchrun mit Gustavo und Sebastian',
        pause:                      168_284,
        sport_type:                 'running',
        start_time:                 Time.parse('2022-09-15T13:15:27Z'),
        start_time_timezone_offset: 0,
        timezone:                   'UTC',
        heart_rate_avg:             152,
        heart_rate_max:             180,
        # trace:                      anything
      }
    end

    it { expect(subject.first).to include(expected_data) }
  end
end

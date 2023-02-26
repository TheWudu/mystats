# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Stats, :clear_db do
  subject do
    described_class.count_per_hour_of_day(
      years:,
      sport_types:,
      group_by:
    )
  end
  let(:years) { nil }
  let(:sport_types) { nil }
  let(:group_by) { { year: '$year' } }

  context 'without sessions available' do
    it { expect(subject).to eq({}) }
  end

  context 'when multiple sessions exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration:       2823,
                        distance:       9678,
                        elevation_gain: 230,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-08-14T10:12:32Z')) # Sunday W31

      FactoryBot.create(:sport_session,
                        duration:       1823,
                        distance:       5678,
                        elevation_gain: 123,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-08-12T07:12:32Z')) # Friday W31

      FactoryBot.create(:sport_session,
                        duration:       3689,
                        distance:       10_678,
                        elevation_gain: 223,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-07-12T07:12:32Z'))

      FactoryBot.create(:sport_session,
                        duration:       3189,
                        distance:       8678,
                        elevation_gain: 524,
                        sport_type:     'cycling',
                        start_time:     Time.parse('2021-04-12T09:12:32Z'))
    end

    let(:expected_hour_per_day) do
      {
        9  => 2,
        11 => 1,
        12 => 1
      }
    end
    it { expect(subject).to eq(expected_hour_per_day) }

    context 'with filters' do
      let(:years) { [2021] }
      let(:sport_types) { ['cycling'] }

      let(:expected_hour_per_day) do
        {
          11 => 1
        }
      end
      it { expect(subject).to eq(expected_hour_per_day) }
    end

    context 'with filters' do
      let(:years) { [2021] }
      let(:sport_types) { ['running'] }

      let(:expected_hour_per_day) { {} }
      it { expect(subject).to eq(expected_hour_per_day) }
    end
  end
end

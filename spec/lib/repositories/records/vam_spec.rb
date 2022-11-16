# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Records, :clear_db do
  let(:years) { nil }
  let(:sport_types) { nil }

  context 'without sessions available' do
    it { expect(described_class.distance(years:, sport_types:)).to eq({}) }
  end

  context 'when sessions exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration_up:    3_423_000,
                        elevation_gain: 800,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-07-12T08:21:56Z'))

      FactoryBot.create(:sport_session,
                        duration_up:    2_823_000,
                        elevation_gain: 250,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-08-14T10:12:32Z')) # Sunday W31
      
      FactoryBot.create(:sport_session,
                        duration_up:    3_600_000,
                        elevation_gain: 750,
                        sport_type:     'cycling',
                        start_time:     Time.parse('2022-06-14T06:35:00Z'))
    end

    describe '#vam' do
      subject { described_class.vam(years:, sport_types:) }

      let(:expected_data) do
        {
          '2022.07.12 10:21:56' => 841.37,
          '2022.06.14 08:35:00' => 750.0,
          '2022.08.14 12:12:32' => 318.81
        }
      end

      it { expect(subject).to eq(expected_data) }

      context 'when it contains not relevant sessions' do
        before do
          FactoryBot.create(:sport_session,
                            duration_up:    0,
                            elevation_gain: 123,
                            sport_type:     'yoga',
                            start_time:     Time.parse('2022-09-09T14:00:00Z'))
        end

        it { expect(subject).to eq(expected_data) }
      end
    end
  end
end

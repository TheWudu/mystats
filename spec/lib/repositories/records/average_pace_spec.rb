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
                        duration:   3_423_000,
                        distance:   10_078,
                        sport_type: 'running',
                        start_time: Time.parse('2022-07-12T08:21:56Z'))

      FactoryBot.create(:sport_session,
                        duration:   2_823_000,
                        distance:   9678,
                        sport_type: 'running',
                        start_time: Time.parse('2022-08-14T10:12:32Z')) # Sunday W31
      FactoryBot.create(:sport_session,
                        duration:   3_223_000,
                        distance:   8978,
                        sport_type: 'running',
                        start_time: Time.parse('2022-08-09T06:45:34Z'))
    end

    describe '#average_pace' do
      subject { described_class.average_pace(years:, sport_types:) }

      let(:expected_data) do
        {
          '2022.08.14 12:12:32' => 4.86,
          '2022.07.12 10:21:56' => 5.66,
          '2022.08.09 08:45:34' => 5.98
        }
      end

      it { expect(subject).to eq(expected_data) }

      context 'when it contains not relevant sessions' do
        before do
          FactoryBot.create(:sport_session,
                            duration:   3_223_000,
                            distance:   0,
                            sport_type: 'yoga',
                            start_time: Time.parse('2022-09-09T14:00:00Z'))
        end

        it { expect(subject).to eq(expected_data) }
      end
    end
  end
end

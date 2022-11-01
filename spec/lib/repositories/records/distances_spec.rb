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
                        distance:   10_078,
                        sport_type: 'treadmill',
                        start_time: Time.parse('2021-07-12T08:21:56Z'))

      FactoryBot.create(:sport_session,
                        distance:   9678,
                        sport_type: 'running',
                        start_time: Time.parse('2022-08-14T10:12:32Z')) # Sunday W31
      FactoryBot.create(:sport_session,
                        distance:   8978,
                        sport_type: 'running',
                        start_time: Time.parse('2022-08-09T06:45:34Z'))
    end

    shared_examples 'calculate distance based values properly' do
      describe '#distance' do
        subject { described_class.distance(years:, sport_types:) }

        it { expect(subject).to eq(expected_distance_data) }
      end

      describe '#distance_per_week' do
        subject { described_class.distance_per_week(years:, sport_types:) }

        it { expect(subject).to eq(expected_distance_per_week_data) }
      end

      describe '#distance_per_month' do
        subject { described_class.distance_per_month(years:, sport_types:) }

        it { expect(subject).to eq(expected_distance_per_month_data) }
      end
    end

    it_behaves_like 'calculate distance based values properly' do
      let(:expected_distance_data) do
        {
          '2021.07.12 10:21:56' => 10.078,
          '2022.08.14 12:12:32' => 9.678,
          '2022.08.09 08:45:34' => 8.978
        }
      end

      let(:expected_distance_per_week_data) do
        {
          '2022-32' => 18.656,
          '2021-28' => 10.078
        }
      end

      let(:expected_distance_per_month_data) do
        {
          '2022-8' => 18.656,
          '2021-7' => 10.078
        }
      end
    end

    context 'when filtering for years' do
      let(:years) { [2022] }

      it_behaves_like 'calculate distance based values properly' do
        let(:expected_distance_data) do
          {
            '2022.08.14 12:12:32' => 9.678,
            '2022.08.09 08:45:34' => 8.978
          }
        end

        let(:expected_distance_per_week_data) do
          {
            '2022-32' => 18.656
          }
        end

        let(:expected_distance_per_month_data) do
          {
            '2022-8' => 18.656
          }
        end
      end
    end

    context 'when filtering for sport_types' do
      let(:sport_types) { ['treadmill'] }

      it_behaves_like 'calculate distance based values properly' do
        let(:expected_distance_data) do
          {
            '2021.07.12 10:21:56' => 10.078
          }
        end

        let(:expected_distance_per_week_data) do
          {
            '2021-28' => 10.078
          }
        end

        let(:expected_distance_per_month_data) do
          {
            '2021-7' => 10.078
          }
        end
      end
    end
  end
end

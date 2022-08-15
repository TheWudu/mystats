# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Statistics::MongoDb, :clear_db do
  let(:instance) do
    described_class.new(
      years: years,
      sport_type_ids: sport_type_ids,
      group_by: group_by
    )
  end
  let(:years) { nil }
  let(:sport_type_ids) { nil }
  let(:group_by) { { year: '$year' } }
  let(:attr) { 'overall_distance' }

  subject { instance.data_per_year(attr) }

  context 'without sessions available' do
    it { expect(subject).to eq({}) }
  end

  context 'when a single session exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration: 1823,
                        distance: 5678,
                        elevation_gain: 123,
                        start_time: Time.parse('2022-08-12T07:12:32Z'))
    end

    shared_examples 'returning correct values' do
      it { expect(subject).to eq(expected_stats) }
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_distance' }
      let(:expected_stats) { { '2022' => 5678 } }
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_duration' }
      let(:expected_stats) { { '2022' => 1823 } }
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_elevation_gain' }
      let(:expected_stats) { { '2022' => 123 } }
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_cnt' }
      let(:expected_stats) { { '2022' => 1 } }
    end
  end

  context 'when multiple sessions exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration: 1823,
                        distance: 5678,
                        elevation_gain: 123,
                        sport_type_id: 1,
                        start_time: Time.parse('2022-08-12T07:12:32Z'))

      FactoryBot.create(:sport_session,
                        duration: 3689,
                        distance: 10_678,
                        elevation_gain: 223,
                        sport_type_id: 1,
                        start_time: Time.parse('2022-07-12T07:12:32Z'))

      FactoryBot.create(:sport_session,
                        duration: 3189,
                        distance: 8678,
                        elevation_gain: 524,
                        sport_type_id: 2,
                        start_time: Time.parse('2021-04-12T07:12:32Z'))
    end

    shared_examples 'returning correct values' do
      it { expect(subject).to eq(expected_stats) }
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_distance' }
      let(:expected_stats) do
        {
          '2022' => 5678 + 10_678,
          '2021' => 8678
        }
      end
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_duration' }
      let(:expected_stats) do
        {
          '2022' => 1823 + 3689,
          '2021' => 3189
        }
      end
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_elevation_gain' }
      let(:expected_stats) do
        {
          '2022' => 123 + 223,
          '2021' => 524
        }
      end
    end

    it_behaves_like 'returning correct values' do
      let(:attr) { 'overall_cnt' }
      let(:expected_stats) do
        {
          '2022' => 2,
          '2021' => 1
        }
      end
    end

    context 'with filters' do
      let(:years) { [2021] }
      let(:group_by) { { year: '$year', month: '$month' } }

      it_behaves_like 'returning correct values' do
        let(:attr) { 'overall_distance' }
        let(:expected_stats) { { '2021-4' => 8678 } }
      end

      it_behaves_like 'returning correct values' do
        let(:attr) { 'overall_duration' }
        let(:expected_stats) { { '2021-4' => 3189 } }
      end

      it_behaves_like 'returning correct values' do
        let(:attr) { 'overall_elevation_gain' }
        let(:expected_stats) { { '2021-4' => 524 } }
      end

      it_behaves_like 'returning correct values' do
        let(:attr) { 'overall_cnt' }
        let(:expected_stats) { { '2021-4' => 1 } }
      end
    end
  end
end

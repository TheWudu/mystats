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

  context 'without sessions available' do
    it { expect(instance.cnt_per_weekday_data).to eq({}) }
    it { expect(instance.cnt_per_week_of_year).to eq([]) }
    it { expect(instance.hour_per_day_data).to eq({}) }
  end

  context 'when multiple sessions exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration: 2823,
                        distance: 9678,
                        elevation_gain: 230,
                        sport_type_id: 1,
                        start_time: Time.parse('2022-08-14T10:12:32Z')) # Sunday W31

      FactoryBot.create(:sport_session,
                        duration: 1823,
                        distance: 5678,
                        elevation_gain: 123,
                        sport_type_id: 1,
                        start_time: Time.parse('2022-08-12T07:12:32Z')) # Friday W31

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
                        sport_type_id: 3,
                        start_time: Time.parse('2021-04-12T09:12:32Z'))
    end

    let(:expected_weekday_data) do
      {
        'Friday' => 1,
        'Monday' => 1,
        'Sunday' => 1,
        'Tuesday' => 1
      }
    end

    let(:expected_week_of_year) do
      [
        { name: 2021, data: { 15 => 1 } },
        { name: 2022, data: {
          28 => 1,
          32 => 2
        } }
      ]
    end
    let(:expected_hour_per_day) do
      {
        9 => 2,
        11 => 1,
        12 => 1
      }
    end
    it { expect(instance.cnt_per_weekday_data).to eq(expected_weekday_data) }
    it { expect(instance.cnt_per_week_of_year).to eq(expected_week_of_year) }
    it { expect(instance.hour_per_day_data).to eq(expected_hour_per_day) }

    context 'with filters' do
      let(:years) { [2021] }
      let(:sport_type_ids) { [3] }

      let(:expected_weekday_data) do
        {
          'Monday' => 1
        }
      end

      let(:expected_week_of_year) do
        [
          { name: 2021, data: { 15 => 1 } }
        ]
      end
      let(:expected_hour_per_day) do
        {
          11 => 1
        }
      end
      it { expect(instance.cnt_per_weekday_data).to eq(expected_weekday_data) }
      it { expect(instance.cnt_per_week_of_year).to eq(expected_week_of_year) }
      it { expect(instance.hour_per_day_data).to eq(expected_hour_per_day) }
    end

    context 'with filters' do
      let(:years) { [2021] }
      let(:sport_type_ids) { [1] }

      let(:expected_weekday_data) { {} }
      let(:expected_week_of_year) { [] }
      let(:expected_hour_per_day) { {} }
      it { expect(instance.cnt_per_weekday_data).to eq(expected_weekday_data) }
      it { expect(instance.cnt_per_week_of_year).to eq(expected_week_of_year) }
      it { expect(instance.hour_per_day_data).to eq(expected_hour_per_day) }
    end
  end
end

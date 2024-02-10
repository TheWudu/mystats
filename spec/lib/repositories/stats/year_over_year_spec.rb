# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Stats, :clear_db do
  subject do
    described_class.year_over_year(
      years:,
      sport_types:,
      group_by:
    )
  end
  let(:years) { [2022, 2021] }
  let(:sport_types) { nil }

  context 'without sessions available' do
    context 'when group_by is week' do
      let(:group_by) { 'week' }

      it { expect(subject.data).to eq([]) }
      it { expect(subject.years).to eq([]) }

      it { expect(subject.value).to eq("-") }
    end

    context 'when group_by is day' do
      let(:group_by) { 'day' }

      it { expect(subject.ending).to eq("day: 10.2.") }
      it { expect(subject.data).to eq([]) }
      it { expect(subject.years).to eq([]) }

      it { expect(subject.value).to eq("-") }
    end

    context 'when group_by is month' do
      let(:group_by) { 'month' }

      it { expect(subject.ending).to eq("month 2") }
      it { expect(subject.data).to eq([]) }
      it { expect(subject.years).to eq([]) }

      it { expect(subject.value).to eq("-") }
    end
  end

  context 'when multiple sessions exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration:       1823,
                        distance:       5678,
                        elevation_gain: 123,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-01-13T07:12:32Z'))

      FactoryBot.create(:sport_session,
                        duration:       3689,
                        distance:       10_678,
                        elevation_gain: 223,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-07-07T07:12:32Z'))

      FactoryBot.create(:sport_session,
                        duration:       3189,
                        distance:       8678,
                        elevation_gain: 524,
                        sport_type:     'cycling',
                        start_time:     Time.parse('2021-01-12T07:12:32Z'))
    end

    context 'when group_by is week' do
      let(:group_by) { 'week' }

      let(:expected_first) do
        {
          0  => 0,
          1  => 0,
          2  => 5.68,
          3  => 5.68,
          4  => 5.68,
          5  => 5.68,
          6  => 5.68,
          7  => 5.68,
          8  => 5.68,
          9  => 5.68,
          10 => 5.68,
          11 => 5.68,
          12 => 5.68,
          13 => 5.68,
          14 => 5.68,
          15 => 5.68,
          16 => 5.68,
          17 => 5.68,
          18 => 5.68,
          19 => 5.68,
          20 => 5.68,
          21 => 5.68,
          22 => 5.68,
          23 => 5.68,
          24 => 5.68,
          25 => 5.68,
          26 => 5.68,
          27 => 16.36,
          28 => 16.36,
          29 => 16.36,
          30 => 16.36,
          31 => 16.36,
          32 => 16.36,
          33 => 16.36,
          34 => 16.36,
          35 => 16.36,
          36 => 16.36,
          37 => 16.36,
          38 => 16.36,
          39 => 16.36,
          40 => 16.36,
          41 => 16.36,
          42 => 16.36,
          43 => 16.36,
          44 => 16.36,
          45 => 16.36,
          46 => 16.36,
          47 => 16.36,
          48 => 16.36,
          49 => 16.36,
          50 => 16.36,
          51 => 16.36,
          52 => 16.36
        }
      end

      let(:expected_last) do
        {
          0  => 0,
          1  => 0,
          2  => 8.68,
          3  => 8.68,
          4  => 8.68,
          5  => 8.68,
          6  => 8.68,
          7  => 8.68,
          8  => 8.68,
          9  => 8.68,
          10 => 8.68,
          11 => 8.68,
          12 => 8.68,
          13 => 8.68,
          14 => 8.68,
          15 => 8.68,
          16 => 8.68,
          17 => 8.68,
          18 => 8.68,
          19 => 8.68,
          20 => 8.68,
          21 => 8.68,
          22 => 8.68,
          23 => 8.68,
          24 => 8.68,
          25 => 8.68,
          26 => 8.68,
          27 => 8.68,
          28 => 8.68,
          29 => 8.68,
          30 => 8.68,
          31 => 8.68,
          32 => 8.68,
          33 => 8.68,
          34 => 8.68,
          35 => 8.68,
          36 => 8.68,
          37 => 8.68,
          38 => 8.68,
          39 => 8.68,
          40 => 8.68,
          41 => 8.68,
          42 => 8.68,
          43 => 8.68,
          44 => 8.68,
          45 => 8.68,
          46 => 8.68,
          47 => 8.68,
          48 => 8.68,
          49 => 8.68,
          50 => 8.68,
          51 => 8.68,
          52 => 8.68
        }
      end

      it { expect(subject.data.map { |s| s[:name] }.sort).to eq([2021, 2022]) }

      it { expect(subject.data.first[:data]).to eq(expected_first) }
      it { expect(subject.data.last[:data]).to eq(expected_last) }

      describe 'value' do
        before do
          allow_any_instance_of(Repositories::Stats::MongoDb::YearOverYear).to receive(:yoy_date)
            .and_return(8)
        end

        it { expect(subject.value).to eq(65.4) }
        it { expect(subject.years).to eq([2021, 2022]) }
      end
    end

    context 'when group_by is month' do
      let(:group_by) { 'month' }

      let(:expected_first) do
        {
          1  => 5.68,
          2  => 5.68,
          3  => 5.68,
          4  => 5.68,
          5  => 5.68,
          6  => 5.68,
          7  => 16.36,
          8  => 16.36,
          9  => 16.36,
          10 => 16.36,
          11 => 16.36,
          12 => 16.36
        }
      end

      let(:expected_last) do
        {
          1  => 8.68,
          2  => 8.68,
          3  => 8.68,
          4  => 8.68,
          5  => 8.68,
          6  => 8.68,
          7  => 8.68,
          8  => 8.68,
          9  => 8.68,
          10 => 8.68,
          11 => 8.68,
          12 => 8.68
        }
      end

      it { expect(subject.data.map { |s| s[:name] }.sort).to eq([2021, 2022]) }

      it { expect(subject.data.first[:data]).to eq(expected_first) }
      it { expect(subject.data.last[:data]).to eq(expected_last) }

      describe 'value' do
        before do
          allow_any_instance_of(Repositories::Stats::MongoDb::YearOverYear).to receive(:yoy_date)
            .and_return(2)
        end

        it { expect(subject.value).to eq(65.4) }
        it { expect(subject.years).to eq([2021, 2022]) }
      end
    end

    context 'when group_by is day' do
      let(:group_by) { 'day' }

      let(:expected_first) do
        {
          '1.1.'   => 0,
          '12.1.'  => 0,
          '13.1.'  => 5.68,
          '6.7.'   => 5.68,
          '7.7.'   => 16.36,
          '31.12.' => 16.36
        }
      end

      let(:expected_last) do
        {
          '11.1.'  => 0,
          '12.1.'  => 8.68,
          '31.12.' => 8.68
        }
      end

      it { expect(subject.data.map { |s| s[:name] }.sort).to eq([2021, 2022]) }

      it { expect(subject.data.first[:data]).to include(expected_first) }
      it { expect(subject.data.last[:data]).to include(expected_last) }

      describe 'value' do
        before do
          allow_any_instance_of(Repositories::Stats::MongoDb::YearOverYear).to receive(:yoy_date)
            .and_return('25.2.')
        end

        it { expect(subject.value).to eq(65.4) }
        it { expect(subject.years).to eq([2021, 2022]) }
      end
    end
  end
end

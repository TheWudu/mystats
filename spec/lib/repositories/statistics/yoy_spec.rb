# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Statistics::MongoDb, :clear_db do
  let(:instance) do
    described_class.new(
      years:,
      sport_types:,
      group_by:
    )
  end
  let(:years) { [2022, 2021] }
  let(:sport_types) { nil }
  let(:group_by) { { year: '$year' } }

  subject { instance.yoy }

  context 'without sessions available' do
    it { expect(subject.map { |s| s[:name] }.sort).to eq([2021, 2022]) }
    it { expect(subject.first[:data][0]).to eq(0) }
    it { expect(subject.first[:data][52]).to eq(0) }
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

    def fill_days(year)
      r = {}
      (Date.parse("#{year}-01-01")..Date.parse("#{year}-01-31")).each do |day|
        r[day.to_s] = 0
      end
      r
    end

    let(:base_data) do
      [
        { name: 2021, data: fill_days(2021) },
        { name: 2022, data: fill_days(2022) }
      ]
    end

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

    it { expect(subject.map { |s| s[:name] }.sort).to eq([2021, 2022]) }

    it { expect(subject.first[:data]).to eq(expected_first) }
    it { expect(subject.last[:data]).to eq(expected_last) }
  end
end

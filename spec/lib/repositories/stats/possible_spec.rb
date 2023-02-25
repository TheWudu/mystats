# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Stats::MongoDb::Possible, :clear_db do
  let(:instance) do
    described_class.new
  end

  context 'without sessions available' do
    it { expect(instance.years).to eq([]) }
    it { expect(instance.sport_types).to eq([]) }
  end

  context 'when multiple sessions exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration:       1823,
                        distance:       5678,
                        elevation_gain: 123,
                        sport_type:     'running',
                        start_time:     Time.parse('2022-08-12T07:12:32Z'))

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
                        start_time:     Time.parse('2021-04-12T07:12:32Z'))
    end

    it { expect(instance.years).to eq([2021, 2022]) }
    it { expect(instance.sport_types.sort).to eq(%w[running cycling].sort) }
  end
end

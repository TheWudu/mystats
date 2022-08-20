# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Statistics::MongoDb, :clear_db do
  let(:instance) do
    described_class.new(
      years:          years,
      sport_type_ids: sport_type_ids,
      group_by:       group_by
    )
  end
  let(:years) { nil }
  let(:sport_type_ids) { nil }
  let(:group_by) { { year: '$year' } }

  context 'without sessions available' do
    it { expect(instance.possible_years).to eq([]) }
    it { expect(instance.possible_sport_types).to eq({}) }
  end

  context 'when multiple sessions exist' do
    before do
      FactoryBot.create(:sport_session,
                        duration:       1823,
                        distance:       5678,
                        elevation_gain: 123,
                        sport_type_id:  1,
                        start_time:     Time.parse('2022-08-12T07:12:32Z'))

      FactoryBot.create(:sport_session,
                        duration:       3689,
                        distance:       10_678,
                        elevation_gain: 223,
                        sport_type_id:  1,
                        start_time:     Time.parse('2022-07-12T07:12:32Z'))

      FactoryBot.create(:sport_session,
                        duration:       3189,
                        distance:       8678,
                        elevation_gain: 524,
                        sport_type_id:  3,
                        start_time:     Time.parse('2021-04-12T07:12:32Z'))
    end

    it { expect(instance.possible_years).to eq([2021, 2022]) }
    it { expect(instance.possible_sport_types).to eq({ 1 => 'running', 3 => 'cycling' }) }
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions, :clear_db do
  describe 'where' do
    let(:id) { SecureRandom.uuid }

    let(:distance_between) { nil }
    let(:id_not_in) { nil }
    let(:trace_exists) { nil }

    let(:opts) do 
      {
        'distance.between' => distance_between,
        'id.not_in' => id_not_in,
        'trace.exists' => trace_exists
      }.compact
    end

    subject { described_class.where(opts: opts) }

    context 'when no sessions exist' do
      it { expect(subject).to be_empty }
    end

    shared_examples 'returns sport-sessions' do
      it { expect(subject.count).to eq(expected_count) }
      it { expect(subject.map(&:id).sort).to eq(expected_ids.sort) }
    end

    context 'when session exists' do
      let(:sport_session_1) do
        FactoryBot.create(:sport_session, distance: 5200)
      end
      let(:sport_session_2) do
        FactoryBot.create(:sport_session, distance: 7200)
      end
      let(:sport_session_3) do
        FactoryBot.create(:sport_session, :with_trace, distance: 7000)
      end

      before do
        sport_session_1
        sport_session_2
        sport_session_3
      end

      it_behaves_like 'returns sport-sessions' do
        let(:distance_between) { [6900, 7300] }
        let(:expected_ids) { [sport_session_2.id, sport_session_3.id] }
        let(:expected_count) { 2 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:distance_between) { [5000, 5500] }
        let(:expected_ids) { [sport_session_1.id] }
        let(:expected_count) { 1 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:trace_exists) { true }
        let(:expected_ids) { [sport_session_3.id] }
        let(:expected_count) { 1 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:id_not_in) { [sport_session_2.id] }
        let(:expected_ids) { [sport_session_1.id, sport_session_3.id] }
        let(:expected_count) { 2 }
      end
    end
  end
end

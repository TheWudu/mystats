# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions, :clear_db do
  describe 'fetch' do
    let(:id) { SecureRandom.uuid }

    let(:years)  { nil }
    let(:months) { nil }
    let(:sport_type_ids) { nil }
    let(:text) { nil }

    subject { described_class.fetch(years: years, months: months, sport_type_ids: sport_type_ids, text: text) }

    context 'when no sessions exist' do
      it { expect(subject).to be_empty }
    end

    shared_examples 'returns sport-sessions' do
      it { expect(subject.count).to eq(expected_count) }
      it { expect(subject.map(&:id).sort).to eq(expected_ids.sort) }
    end

    context 'when session exists' do
      let(:sport_session_1) do
        FactoryBot.create(:sport_session, start_time: Time.parse('2022-08-12T00:07:02Z'))
      end
      let(:sport_session_2) do
        FactoryBot.create(:sport_session, start_time: Time.parse('2022-07-12T00:07:02Z'))
      end
      let(:sport_session_3) do
        FactoryBot.create(:sport_session, start_time: Time.parse('2021-08-12T00:07:02Z'), sport_type_id: 2)
      end

      before do
        sport_session_1
        sport_session_2
        sport_session_3
      end

      it_behaves_like 'returns sport-sessions' do
        let(:expected_ids) { [sport_session_1.id, sport_session_2.id, sport_session_3.id] }
        let(:expected_count) { 3 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:years) { [2022] }
        let(:expected_ids) { [sport_session_1.id, sport_session_2.id] }
        let(:expected_count) { 2 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:years) { [2022] }
        let(:months) { [8] }
        let(:expected_ids) { [sport_session_1.id] }
        let(:expected_count) { 1 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:years) { [2022] }
        let(:months) { [8] }
        let(:sport_type_ids) { [2] }
        let(:expected_ids) { [] }
        let(:expected_count) { 0 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:years) { [2021] }
        let(:sport_type_ids) { [2] }
        let(:expected_ids) { [sport_session_3.id] }
        let(:expected_count) { 1 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:years) { [2021, 2022] }
        let(:sport_type_ids) { [1, 2] }
        let(:expected_ids) { [sport_session_1.id, sport_session_2.id, sport_session_3.id] }
        let(:expected_count) { 3 }
      end
    end

    describe 'text search' do
      let(:sport_session_1) { FactoryBot.create(:sport_session, notes: 'Around the lake') }
      let(:sport_session_2) { FactoryBot.create(:sport_session, notes: 'Up and around the Tannberg') }

      before do
        sport_session_1
        sport_session_2
      end

      it_behaves_like 'returns sport-sessions' do
        let(:text) { 'around' }
        let(:expected_ids) { [sport_session_1.id, sport_session_2.id] }
        let(:expected_count) { 2 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:text) { 'lake' }
        let(:expected_ids) { [sport_session_1.id] }
        let(:expected_count) { 1 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:text) { 'Tannberg' }
        let(:expected_ids) { [sport_session_2.id] }
        let(:expected_count) { 1 }
      end
    end
  end
end

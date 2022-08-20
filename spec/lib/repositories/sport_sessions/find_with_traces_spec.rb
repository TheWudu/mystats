# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions, :clear_db do
  describe 'where' do
    let(:id) { SecureRandom.uuid }

    let(:year) { nil }
    let(:month) { nil }
    let(:sport_type_id) { nil }
    let(:id_not_in) { nil }
    let(:trace_exists) { nil }

    let(:opts) do
      {
        year: year,
        month: month,
        sport_type_id: sport_type_id,
        'id.not_in' => id_not_in
      }.compact
    end

    subject { described_class.find_with_traces(opts: opts) }

    context 'when no sessions exist' do
      it { expect(subject).to be_empty }
    end

    shared_examples 'returns sport-sessions' do
      it { expect(subject.count).to eq(expected_count) }
      it { expect(subject.map(&:id).sort).to eq(expected_ids.sort) }
    end

    context 'when session exists' do
      let(:sport_session_1) do
        FactoryBot.create(:sport_session, :with_trace, start_time:    Time.parse('2022-08-12T07:08:23Z'),
                                                       sport_type_id: 1)
      end
      let(:sport_session_2) do
        FactoryBot.create(:sport_session, :with_trace, start_time:    Time.parse('2022-07-12T09:26:23Z'),
                                                       sport_type_id: 2)
      end
      let(:sport_session_3) do
        FactoryBot.create(:sport_session, :with_trace, start_time:    Time.parse('2021-08-12T12:56:23Z'),
                                                       sport_type_id: 1)
      end

      before do
        sport_session_1
        sport_session_2
        sport_session_3
      end

      it_behaves_like 'returns sport-sessions' do
        let(:id_not_in)      { [sport_session_1.id] }
        let(:expected_ids)   { [sport_session_2.id, sport_session_3.id] }
        let(:expected_count) { 2 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:year) { [2022] }
        let(:expected_ids) { [sport_session_1.id, sport_session_2.id] }
        let(:expected_count) { 2 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:month) { [8] }
        let(:expected_ids) { [sport_session_1.id, sport_session_3.id] }
        let(:expected_count) { 2 }
      end

      it_behaves_like 'returns sport-sessions' do
        let(:sport_type_id) { [2] }
        let(:expected_ids) { [sport_session_2.id] }
        let(:expected_count) { 1 }
      end
    end
  end
end

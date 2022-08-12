# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions do
  describe 'find_by_id' do
    let(:id1) { SecureRandom.uuid }
    let(:id2) { SecureRandom.uuid }
    let(:ids) { [id1, id2] }
    let(:sort) { nil }

    subject { described_class.find_by_ids(ids: ids, sort: sort) }

    context 'when sessions does not exist' do
      it { expect(subject).to eq([]) }
    end

    context 'when one of two sessions exists' do
      let(:sport_session_1) { FactoryBot.create(:sport_session, id: id1) }

      before do
        sport_session_1
      end

      it { expect(subject).to eq([sport_session_1]) }
    end

    context 'when both sessions exist' do
      let(:sport_session_1) { FactoryBot.create(:sport_session, id: id1) }
      let(:sport_session_2) { FactoryBot.create(:sport_session, id: id2) }

      before do
        sport_session_1
        sport_session_2
      end

      it { expect(subject.map(&:id).sort).to eq([id1, id2].sort) }
    end

    context 'with sorting' do
      let(:sport_session_1) do
        FactoryBot.create(:sport_session, id: id1, duration: 1, distance: 1, start_time: Time.at(1.hour.ago.to_i))
      end
      let(:sport_session_2) do
        FactoryBot.create(:sport_session, id: id2, duration: 2, distance: 2, start_time: Time.at(2.hour.ago.to_i))
      end

      before do
        sport_session_1
        sport_session_2
      end

      describe 'by duration asc' do
        let(:sort) { { attribute: 'duration', direction: :asc } }
        it { expect(subject.map(&:id)).to eq([id1, id2]) }
      end

      describe 'by start_time asc' do
        let(:sort) { { attribute: 'start_time', direction: :asc } }
        it { expect(subject.map(&:id)).to eq([id2, id1]) }
      end

      describe 'by distance desc' do
        let(:sort) { { attribute: 'distance', direction: :desc } }
        it { expect(subject.map(&:id)).to eq([id2, id1]) }
      end
    end
  end
end

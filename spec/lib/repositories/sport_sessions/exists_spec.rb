# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions do
  describe 'exists?' do
    let(:id) { SecureRandom.uuid }

    subject { described_class.exists?(start_time: start_time, sport_type: sport_type) }

    context 'when session does not exist' do
      let(:start_time) { Time.now }
      let(:sport_type) { 'running' }

      it { expect(subject).to be_falsey }
    end

    context 'when session exists' do
      let(:sport_session) do
        FactoryBot.create(:sport_session, id: id)
      end
      let(:start_time) { sport_session.start_time }
      let(:sport_type) { sport_session.sport_type }

      before do
        sport_session
      end

      it { expect(subject).to be_truthy }

      context 'when searching for slightly different start_time' do
        let(:start_time) { sport_session.start_time - 30.seconds }

        it { expect(subject).to be_truthy }
      end
    end
  end
end

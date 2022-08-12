# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions do
  describe 'find_by_id' do
    let(:id) { SecureRandom.uuid }

    subject { described_class.find_by_id(id: id) }

    context 'when session does not exist' do
      it { expect(subject).to be_nil }
    end

    context 'when session exists' do
      let(:sport_session) do
        FactoryBot.create(:sport_session, id: id)
      end

      before do
        sport_session
      end

      it { expect(subject).to be_a(Models::SportSession) }
    end
  end
end

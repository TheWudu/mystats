# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions do
  describe 'delete' do
    let(:id) { SecureRandom.uuid }

    subject { described_class.delete(id: id) }

    context 'when session does not exist' do
      it { expect(subject).to be_falsey }
    end

    context 'when session exists' do
      let(:sport_session) do
        FactoryBot.create(:sport_session, id: id)
      end

      before do
        sport_session
      end

      it { expect(subject).to be_truthy }
      it "can't find session after delete" do
        expect { subject }.to change { Repositories::SportSessions.find_by_id(id: id) }.from(sport_session).to(nil)
      end
    end
  end
end

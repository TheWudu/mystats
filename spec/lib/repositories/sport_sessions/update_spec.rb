# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions, :clear_db do
  describe 'update' do
    let(:id) { SecureRandom.uuid }
    let(:update_hash) do
      insert_hash
    end
    let(:insert_hash) do
      FactoryBot.attributes_for(:sport_session, id:)
    end

    subject { described_class.update(session_hash: update_hash) }

    context 'when session does not exist' do
      it { expect(subject).to be(false) }
    end

    context 'when session exists' do
      before do
        described_class.insert(session_hash: insert_hash)
      end

      it { expect(subject).to be(true) }

      describe 'does not change protected attributes' do
        let(:update_hash) do
          insert_hash.merge(
            _id: SecureRandom.uuid,
            id:  SecureRandom.uuid
          )
        end

        def count_sessions
          Repositories::SportSessions.fetch(years: nil, months: nil, sport_types: nil).count
        end

        it { expect(subject).to be(true) }
        it {
          subject
          expect(described_class.find_by_id(id: insert_hash[:id])).to be_a(Models::SportSession)
        }
        it {
          subject
          expect(described_class.find_by_id(id: update_hash[:id])).to be_nil
        }

        it { expect { subject }.not_to change { count_sessions } }
      end
    end
  end
end

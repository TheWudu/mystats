# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Courses, :clear_db do
  let(:id) { SecureRandom.uuid }

  describe '#delete' do
    subject { described_class.delete(id:) }

    context 'when session exist' do
      let(:course) { FactoryBot.create(:course, id:) }

      before do
        course
      end

      it { expect(subject).to eq(true) }

      it { expect { subject }.to change { described_class.find(id:) }.from(course).to(nil) }
    end

    context 'when session does not exist' do
      it { expect(subject).to eq(false) }
    end
  end
end

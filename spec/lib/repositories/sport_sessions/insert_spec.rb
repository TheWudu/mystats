# frozen_string_literal: true

require 'rails_helper'

describe Repositories::SportSessions do
  describe 'insert' do
    subject { described_class.insert(session: session_hash) }

    let(:session_hash) { FactoryBot.attributes_for(:sport_session) }

    it { expect(subject).to be(true) }


    context "when start_time is missing" do 
      let(:session_hash) { super().except(:start_time) }

      it { expect{subject}.to raise_error(ArgumentError) }
    end
  end
end

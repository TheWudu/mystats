require 'rails_helper' 

describe Repositories::SportSessions do

  describe "find_by_id" do
    let(:id1) { SecureRandom.uuid }
    let(:id2) { SecureRandom.uuid }
    let(:ids) { [id1, id2] }

    subject { described_class.find_by_ids(ids: ids) }

    context "when sessions does not exist" do
      it { expect(subject).to eq([]) } 
    end

    context "when one of two sessions exists" do
      let(:sport_session_1) { FactoryBot.create(:sport_session, id: id1) }

      before do
        sport_session_1
      end

      it { expect(subject.first.as_json).to eq(sport_session_1.as_json) }
    end

    context "when both sessions exist" do
      let(:sport_session_1) { FactoryBot.create(:sport_session, id: id1) }
      let(:sport_session_2) { FactoryBot.create(:sport_session, id: id2) }

      before do
        sport_session_1
        sport_session_2
      end

      it { expect(subject.map(&:id).sort).to eq([id1, id2].sort) }
    end
  end
end

require "rails_helper"

describe Repositories::Courses, :clear_db do

  subject { described_class.session_ids }

  context "when no courses exist" do 
    it { expect(subject).to eq([]) }
  end

  context "when a course without session_ids exist" do 
    let(:course) { FactoryBot.create(:course) }

    before do
      course
    end
    
    it { expect(subject).to eq([]) }
  end

  context "when multiple courses with session_ids exist" do
    let(:course_abc) { FactoryBot.create(:course, session_ids: ["abc", "def"]) }
    let(:course_ghi) { FactoryBot.create(:course, session_ids: ["ghi", "jkl"]) }

    before do
      course_ghi
      course_abc
    end

    it "returns courses sorted by name" do 
      expect(subject.sort).to eq(["abc","def","ghi","jkl"])
    end
  end


end

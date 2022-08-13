require "rails_helper"

describe Repositories::Courses, :clear_db do

  let(:id) { SecureRandom.uuid }

  describe "#insert" do 
    let(:course) { FactoryBot.build(:course, id: id) }

    subject { described_class.insert(course: course) }

    it { expect(subject).to eq(true) }

    it { expect{subject}.to change{described_class.find(id: id)}.from(nil).to(course) }
  end
end

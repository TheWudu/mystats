require "rails_helper"

describe Repositories::Courses, :clear_db do

  let(:id) { SecureRandom.uuid }

  describe "#update" do 
    let(:course) { FactoryBot.create(:course, id: id, name: "my awesome c") }
    let(:updated_course) do
      course.dup.tap do |c|
        c.name = "my awesome course"
      end
    end

    before do
      course
    end

    subject { described_class.update(course: updated_course) }

    it { expect(subject).to eq(true) }

    it { expect{subject}.to change{described_class.find(id: id).name}.from("my awesome c").to("my awesome course") }
    it { expect{subject}.to change{described_class.find(id: id)}.from(course).to(updated_course) }
  end
end

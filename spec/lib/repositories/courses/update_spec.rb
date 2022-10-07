# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Courses, :clear_db do
  let(:id) { SecureRandom.uuid }

  describe '#update' do
    let(:course) { FactoryBot.create(:course, id:, name: 'my awesome c') }
    let(:updated_course) do
      # the following line would work with this PR:
      # https://github.com/Goltergaul/definition/pull/36
      # course.new(name: 'my awesome course')
      course.class.new(course.merge(name: 'my awesome course'))
    end

    before do
      course
    end

    subject { described_class.update(course: updated_course) }

    it { expect(subject).to eq(true) }

    it {
      expect { subject }.to change {
                              described_class.find(id:).name
                            }.from('my awesome c').to('my awesome course')
    }
    it { expect { subject }.to change { described_class.find(id:) }.from(course).to(updated_course) }
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Courses do
  let(:id) { SecureRandom.uuid }
  subject { described_class.find(id:) }

  context 'when no courses exist' do
    it { expect(subject).to eq(nil) }
  end

  context 'when a course exist' do
    let(:course) { FactoryBot.create(:course, id:) }

    before do
      course
    end

    it { expect(subject).to eq(course) }
    it { expect(subject).to be_a(Models::Course) }
  end

  context 'when multiple courses exist' do
    let(:course_abc) { FactoryBot.create(:course, name: 'route abc') }
    let(:course_xzv) { FactoryBot.create(:course, id:, name: 'route xzv') }

    before do
      course_xzv
      course_abc
    end

    it 'returns correct course' do
      expect(subject).to eq(course_xzv)
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Courses, :clear_db do
  subject { described_class.fetch }

  context 'when no courses exist' do
    it { expect(subject).to eq([]) }
  end

  context 'when a course exist' do
    let(:course) { FactoryBot.create(:course) }

    before do
      course
    end

    it { expect(subject).to eq([course]) }
  end

  context 'when multiple courses exist' do
    let(:course_abc) { FactoryBot.create(:course, name: 'route abc') }
    let(:course_xzv) { FactoryBot.create(:course, name: 'route xzv') }
    let(:course_jkl) { FactoryBot.create(:course, name: 'route jkl') }

    before do
      course_xzv
      course_jkl
      course_abc
    end

    it 'returns courses sorted by name' do
      expect(subject).to eq([course_abc, course_jkl, course_xzv])
    end
  end
end

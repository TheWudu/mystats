# frozen_string_literal: true

require 'rails_helper'

describe Repositories::Courses do
  let(:id) { SecureRandom.uuid }

  subject { described_class.find_by_session_id(id: id) }

  let(:sport_session) { FactoryBot.create(:sport_session, id: id) }
  let(:course) { FactoryBot.create(:course, session_ids: session_ids) }

  before do
    course
  end

  context 'when sport session is not listed in a course' do
    let(:session_ids) { [] }

    it { expect(subject).to eq(nil) }
  end

  context 'when sport session is listed in a course' do
    let(:session_ids) { [sport_session.id] }

    it { expect(subject).to eq(course) }
  end
end

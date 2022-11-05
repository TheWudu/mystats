# frozen_string_literal: true

require 'rails_helper'

describe UseCases::Session::ImportGpx, :clear_db do
  let(:input_file) { 'spec/fixtures/traces/running_8km.gpx' }
  let(:data) { File.read(input_file) }

  subject { described_class.new(data:).run }

  def sport_sessions_count
    Repositories::SportSessions.fetch(years: [2022], months: nil, sport_types: nil).count
  end

  it { expect { subject }.to change { sport_sessions_count }.from(0).to(1) }

  context 'when same session already exists' do
    let(:parsed_session) { Parser::Gpx.new(data:).parse.first }
    before do
      Repositories::SportSessions.insert(session_hash: parsed_session)
    end

    it { expect { subject }.not_to change { sport_sessions_count } }
  end
end

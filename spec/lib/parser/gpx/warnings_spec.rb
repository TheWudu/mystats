# frozen_string_literal: true

require 'rails_helper'

describe Parser::Gpx do
  let(:input_file) { 'spec/fixtures/traces/running_8km.gpx' }
  let(:data) { File.read(input_file) }

  let(:parser) { described_class.new(data: data) }
  subject { parser.parse }

  context 'when cities are not imported' do
    before do
      allow(Repositories::Cities).to receive(:count).and_return(0)
    end

    it 'expected warning is listed' do
      subject
      expect(parser.warnings.count).to eq(1)
      expect(parser.warnings.first).to eq('Cities not imported, timezone might be wrong')
    end
  end

  context 'when elevation refinment fails' do
    before do
      allow(Repositories::Cities).to receive(:count).and_return(1)
      allow(HgtReader).to receive(:new).and_raise(StandardError.new('failing'))
    end

    it 'expect warning is listed' do
      subject
      expect(parser.warnings.count).to eq(1)
      expect(parser.warnings.first).to eq('failing')
    end
  end
end

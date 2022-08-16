# frozen_string_literal: true

require 'rails_helper'

describe UseCases::Traces::Matcher do
  subject(:matcher) do
    described_class.new(trace1: trace1, trace2: trace2, block_size: block_size, min_overlap: min_overlap)
  end

  let(:block_size) { nil }
  let(:min_overlap) { nil }
  let(:trace1) { JSON.parse(File.read('spec/fixtures/traces/running_20220807_8km.json')) }
  let(:trace2) { JSON.parse(File.read('spec/fixtures/traces/running_20220815_8km.json')) }

  before do
    matcher.analyse
  end

  shared_examples 'matching' do
    it { expect(matcher.matching?).to eq(true) }
    it { expect(matcher.match_in_percent).to eq(match_in_percent) }
  end

  shared_examples 'not matching' do
    it { expect(matcher.matching?).to eq(false) }
  end

  context 'when using defaults' do
    it_behaves_like 'matching' do
      let(:match_in_percent) { 80.44 }
    end
  end

  context 'with bigger block-size' do
    let(:block_size) { 50 }
    it_behaves_like 'matching' do
      let(:match_in_percent) { 87.67 }
    end
  end

  context 'with higher min_overlap' do
    let(:min_overlap) { 90 }
    it_behaves_like 'not matching'
  end

  context 'with much lower block_size but also lower min_overlap' do
    let(:block_size) { 10 }
    let(:min_overlap) { 25 }
    it_behaves_like 'matching' do
      let(:match_in_percent) { 26.87 }
    end
  end

  context 'when traces are 100% equal' do
    let(:trace2) { trace1 }

    it_behaves_like 'matching' do
      let(:match_in_percent) { 100.0 }
    end
  end
end

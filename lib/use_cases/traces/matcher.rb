# frozen_string_literal: true

require 'fast_polylines'

module UseCases
  module Traces
    class Matcher
      BLOCK_SIZE_IN_METERS = 30
      MIN_OVERLAP = 60 # %

      attr_accessor :trace1, :trace2, :blocks1, :blocks2, :match_in_percent,
                    :block_size, :min_overlap, :orig1, :orig2

      def initialize(trace1:, trace2:, block_size: nil,  min_overlap: nil)
        self.trace1 = trace1
        self.trace2 = trace2
        self.block_size  = block_size&.to_i || BLOCK_SIZE_IN_METERS
        self.min_overlap = min_overlap&.to_f || MIN_OVERLAP
      end

      def analyse
        return unless trace1 || trace2
        self.blocks1 = trace1.map { |p| blockify(p) }.uniq
        self.blocks2 = trace2.map { |p| blockify(p) }.uniq
        self.orig1   = trace1.map { |p| blockify(p, 1) }
        self.orig2   = trace2.map { |p| blockify(p, 1) }

        diffs = find_matches_v2
        self.match_in_percent = ((diffs.count(true).to_f / diffs.count) * 100).round(2)
      end

      def find_matches_v2
        diffs = []
        blocks1.each do |b1|
          diffs << find_match(b1)
        end
        diffs
      end

      def find_match(b1)
        !!blocks2.find_index { |b2| b2 == b1 }
      end

      def matching?
        return false unless match_in_percent
        match_in_percent > min_overlap
      end

      def calc(val)
        (6370 * Math::PI * val / 180 * 1000)
      end

      def blockify(point, bs = block_size)
        [
          (calc(point['lng'].to_f).to_i / bs).to_i * bs + bs / 2,
          (calc(point['lat'].to_f).to_i / bs).to_i * bs + bs / 2
        ]
      end
    end
  end
end

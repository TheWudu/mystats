# frozen_string_literal: true

require 'fast_polylines'

module UseCases
  module Traces
    class Matcher
      BLOCK_SIZE_IN_METERS = 30
      MIN_OVERLAP = 60 # %

      attr_accessor :trace1, :trace2, :blocks1, :blocks2, :match_in_percent,
                    :block_size, :min_overlap, :orig1, :orig2, 
                    :lat_lng_blocks1, :lat_lng_blocks2

      def initialize(trace1:, trace2:, block_size: nil, min_overlap: nil)
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


        self.lat_lng_blocks1 = bounds(blocks1) 
        self.lat_lng_blocks2 = bounds(blocks2) 

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

      def find_match(block1)
        !!blocks2.find_index { |block2| block2 == block1 }
      end

      def matching?
        return false unless match_in_percent

        match_in_percent > min_overlap
      end

      def calc(val)
        (6370 * Math::PI * val / 180 * 1000)
      end

      def uncalc(val)
        (val * 180 / 6370 / Math::PI / 1000)
      end

      def to_lat_lng(block)
        lng1 = uncalc(block[0])
        lng2 = uncalc(block[0] + block_size)
        lat1 = uncalc(block[1])
        lat2 = uncalc(block[1] + block_size)

        [[lat1, lng1],[lat2, lng2]]
      end

      def bounds(blocks)
        blocks.map do |b|
          to_lat_lng(b)
        end
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

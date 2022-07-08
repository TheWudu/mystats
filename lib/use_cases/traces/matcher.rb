require "fast_polylines"

module UseCases
  module Traces
    class Matcher

      BLOCK_SIZE_IN_METERS = 30
      MAX_DIFF = 2
      MIN_OVERLAP = 0.60 # %

      attr_accessor :trace1, :trace2, :blocks1, :blocks2, :match_in_percent,
        :block_size, :max_diff, :min_overlap, :orig1, :orig2

      def initialize(trace1:, trace2:, block_size:, max_diff:, min_overlap:)
        self.trace1 = trace1
        self.trace2 = trace2
        self.block_size  = block_size&.to_i || BLOCK_SIZE_IN_METERS
        self.max_diff    = max_diff&.to_i || MAX_DIFF
        self.min_overlap = min_overlap&.to_f || MIN_OVERLAP
      end

      def analyse
        self.blocks1 = trace1.map { |p| blockify(p) }.uniq
        self.blocks2 = trace2.map { |p| blockify(p) }.uniq
        self.orig1   = trace1.map { |p| blockify(p, 1) }
        self.orig2   = trace2.map { |p| blockify(p, 1) }

        diffs = find_matches_v2
        self.match_in_percent = ((diffs.count(true).to_f / diffs.count)  * 100).round(2)
      end

      def find_matches_v2
        diffs = []
        blocks1.each do |b1|
          diffs << find_match(b1)
        end
        diffs
      end

      def find_match(b1)
        b2 = blocks2.find { |b2| b2 == b1 }
        !!b2
      end
        

      def find_matches
        diffs = [] 
        diff_vals = []
        blocks1.each_with_index do |b1, idx|
          break if idx >= blocks2.size
          b2 = blocks2[idx]
          in_range = (b1[0] - b2[0]).abs <= max_diff ||
                     (b1[1] - b2[1]).abs <= max_diff
          diff_vals << [b1, b2, (b1[0] - b2[0]).abs, (b1[1] - b2[1]).abs]
          diffs << in_range
        end
        diffs
      end
      
      def matching?
        match_in_percent > min_overlap
      end

      def calc(val)
        (6370 * Math::PI * val / 180 * 1000)
      end

      def blockify(point, bs = self.block_size)
        [
          (calc(point["lng"].to_f).to_i / bs).to_i * bs + bs/2, 
          (calc(point["lat"].to_f).to_i / bs).to_i * bs + bs/2
        ]
      end

    end
  end
end

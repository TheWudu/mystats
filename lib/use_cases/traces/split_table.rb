# frozen_string_literal: true

module UseCases
  module Traces
    class SplitTable
      attr_accessor :trace, :result

      def initialize(trace:)
        Geokit.default_units = :meters

        self.trace = trace
        self.result = {}
      end

      def run
        last_km_point = trace.first
        pause = 0

        prev_point = trace.first
        prev_point['distance'] = 0
        trace[1..].each do |cur_point|
          cur_point['distance'] = prev_point['distance'] + calc_distance(cur_point, prev_point)
          if (d = cur_point['time'] - prev_point['time']) > 10
            pause += d
          end

          if ((cur_point['distance'] - last_km_point['distance']) / 1000).to_i.positive?
            store_km(cur_point, last_km_point, pause)

            last_km_point = cur_point
            pause = 0
          end
          prev_point = cur_point
        end

        store_km(trace.last, last_km_point, pause, :to_f) if last_km_point != trace.last
        result.transform_values! { |v| format_s(v.to_i) }
        result
      end

      def store_km(cur_point, last_km_point, pause, m = :to_i)
        distance_diff = cur_point['distance'] - last_km_point['distance']
        duration_diff = cur_point['time'] - last_km_point['time'] - pause

        f = (1000 / distance_diff)

        km = (cur_point['distance'] / 1000).send(m).round(2)
        result[km.to_f] = (duration_diff * f).round(2)
      end

      def format_s(secs)
        mins, secs = secs.divmod(60)
        hours, mins = mins.divmod(60)
        hours = nil if hours.zero?

        [hours, mins, secs].compact.map { |e| e.to_s.rjust(2, '0') }.join ':'
      end

      def calc_distance(cur_point, prev_point)
        prev = Geokit::LatLng.new(prev_point['lat'].to_f, prev_point['lng'].to_f)
        cur  = Geokit::LatLng.new(cur_point['lat'].to_f, cur_point['lng'].to_f)
        prev.distance_to(cur)
      end
    end
  end
end

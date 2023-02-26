# frozen_string_literal: true

require 'awesome_print'
require 'time'
require 'tzinfo'
require 'pry'
require 'geokit'
require_relative '../repositories/cities'

require 'hgt_reader'
require 'stringio'
require 'fit4ruby'
require 'tempfile'

module Parser
  class Fit
    attr_reader :data, :warnings, :pause_threshold, :to_slow

    def initialize(data:)
      @data = data
      @warnings = []

      Geokit.default_units = :meters
    end

    def parse # rubocop:disable Metrics/AbcSize
      timezone = timezone_for(trace.first)
      start_time = fit_file.timestamp - fit_file.total_timer_time.to_i

      stats = {
        id:                         SecureRandom.uuid,
        distance:                   fit_file.total_distance.to_i,
        duration:                   (fit_file.total_timer_time * 1000).to_i,
        end_time:                   fit_file.timestamp,
        notes:                      nil,
        sport_type:                 fit_file.sport,
        start_time:,
        start_time_timezone_offset: timezone_offset(timezone, start_time),
        timezone:,
        pause:,
        heart_rate_avg:             0,
        heart_rate_max:             0,
        elevation_gain:             0,
        elevation_loss:             0,
        trace:
      }
      calculate_trace_based_values(stats)

      [stats]
    end

    private

    def pause
      ((fit_file.records.last.timestamp - fit_file.records.first.timestamp - fit_file.total_timer_time) * 1000).to_i
    end

    def timezone_for(point)
      city = Repositories::Cities.nearest(lat: point[:lat].to_f, lng: point[:lng].to_f)
      return city[:timezone] if city

      cities_count = Repositories::Cities.count
      @warnings << 'Cities not imported, timezone might be wrong' if cities_count.zero?

      'UTC'
    end

    def timezone_offset(timezone, time)
      TZInfo::Timezone.get(timezone).to_local(time).utc_offset
    end

    def calc_hr_values(points, stats)
      hr_values = points.map { |p| p[:hr] }.compact
      return if hr_values.blank?

      stats[:heart_rate_max] = hr_values.max
      stats[:heart_rate_avg] = (hr_values.sum / hr_values.size).to_i
    end

    def calculate_trace_based_values(stats)
      prev_point = trace.first
      trace[1..].each do |cur_point|
        # calc_pause(cur_point, stats)
        calc_elevation(cur_point, prev_point, stats)
        # calc_distance(cur_point, stats)
        prev_point = cur_point
      end

      stats[:elevation_loss] = stats[:elevation_loss].to_i
      stats[:elevation_gain] = stats[:elevation_gain].to_i

      calc_hr_values(trace, stats)
    end

    def calc_elevation(cur_point, prev_point, stats)
      elevation = cur_point[:ele] - prev_point[:ele]
      if elevation.negative?
        stats[:elevation_loss] += elevation.abs
      else
        stats[:elevation_gain] += elevation
      end
    end

    def trace
      @trace ||= fit_file.records.map do |r,|
        {
          time: r.timestamp,
          lat:  r.position_lat,
          lng:  r.position_long,
          ele:  refined_elevation(r.altitude, r.position_lat, r.position_long),
          hr:   r.heart_rate
        }.compact
      end
    end

    def refined_elevation(ele, lat, lng)
      return ele unless lat && lng

      HgtReader.new.elevation(lat, lng)
    rescue StandardError => e
      @warnings << e.message unless warnings.include?(e.message)
      ele
    end

    def fit_file
      @fit_file ||= begin
        file = Tempfile.new('fit_file')
        file.write(data)

        fit = Fit4Ruby.read(file)
        file.close
        fit
      end
    end
  end
end

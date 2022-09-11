# frozen_string_literal: true

require 'awesome_print'
require 'time'
require 'tzinfo'
require 'pry'
require 'geokit'
require_relative '../repositories/cities'

require_relative 'xml'
require 'hgt_reader'

module Parser
  class Gpx
    attr_reader :data, :warnings

    def initialize(data:)
      @data = data
      @warnings = []
    end

    def parse # rubocop:disable Metrics/AbcSize
      tracks.map do |track|
        stats = calculate_track(track)
        timezone = timezone_for(track[:points].first)
        duration = ((track[:points].last[:time] - track[:points].first[:time] - stats[:pause]) * 1000).to_i

        stats.merge({
                      id:                         SecureRandom.uuid,
                      notes:                      track[:name],
                      sport_type:                 SportType.unified(name: track[:type]),
                      start_time:                 track[:points].first[:time],
                      end_time:                   track[:points].last[:time],
                      duration:                   duration,
                      pause:                      (stats[:pause] * 1000).to_i,
                      timezone:                   timezone,
                      start_time_timezone_offset: timezone_offset(timezone, track[:points].first[:time]).to_i,
                      trace:                      trace_from_track(track)
                    })
      end
    end

    private

    def trace_from_track(track)
      track[:points].map do |p|
        {
          time: p[:time],
          lat:  p[:lat].to_f,
          lng:  p[:lon].to_f,
          ele:  p[:ele],
          hr:   p[:heart_rate]
        }
      end
    end

    def timezone_for(point)
      city = Repositories::Cities.nearest(lat: point[:lat].to_f, lng: point[:lon].to_f)
      return city[:timezone] if city

      cities_count = Repositories::Cities.count
      @warnings << 'Cities not imported, timezone might be wrong' if cities_count.zero?

      'UTC'
    end

    def timezone_offset(timezone, time)
      TZInfo::Timezone.get(timezone).to_local(time).utc_offset
    end

    def calculate_track(track)
      Geokit.default_units = :meters

      stats = {
        elevation_gain: 0,
        elevation_loss: 0,
        distance:       0,
        pause:          0,
        heart_rate_avg: 0,
        heart_rate_max: 0
      }

      prev_point = track[:points].first
      track[:points][1..].each do |cur_point|
        calc_pause(cur_point, prev_point, stats)
        calc_elevation(cur_point, prev_point, stats)
        calc_distance(cur_point, prev_point, stats)
        prev_point = cur_point
      end

      calc_hr_values(track[:points], stats)

      stats.transform_values!(&:to_i)
    end

    def calc_elevation(cur_point, prev_point, stats)
      elevation = cur_point[:ele] - prev_point[:ele]
      if elevation.negative?
        stats[:elevation_loss] += elevation.abs
      else
        stats[:elevation_gain] += elevation
      end
    end

    def calc_hr_values(points, stats)
      hr_values = points.map { |p| p[:heart_rate] }.compact
      return if hr_values.blank?

      stats[:heart_rate_max] = hr_values.max
      stats[:heart_rate_avg] = (hr_values.sum / hr_values.size).to_i
    end

    PAUSE_THRESHOLD = 10

    def calc_pause(cur_point, prev_point, stats)
      duration = cur_point[:time].to_f - prev_point[:time].to_f
      stats[:pause] += duration if duration > PAUSE_THRESHOLD
      duration > PAUSE_THRESHOLD
    end

    def calc_distance(cur_point, prev_point, stats)
      prev = Geokit::LatLng.new(prev_point[:lat].to_f, prev_point[:lon].to_f)
      cur  = Geokit::LatLng.new(cur_point[:lat].to_f, cur_point[:lon].to_f)
      stats[:distance] += prev.distance_to(cur)
    end

    def tracks # rubocop:disable Metrics/AbcSize
      gpx = xml.first
      @tracks ||= gpx[:tags].select { |t| t[:tag] == 'trk' }.map do |trk|
        {
          name:   tag_data(trk, 'name'),
          type:   tag_data(trk, 'type'),
          points: trk[:tags].select { |t| t[:tag] == 'trkseg' }.map do |trkseg|
            trkseg[:tags].select { |t| t[:tag] == 'trkpt' }.map do |trkpt|
              trkpt[:meta].merge(
                time:       Time.parse(from_tags(trkpt, 'time')),
                ele:        refined_elevation(from_tags(trkpt, 'ele').to_f, trkpt[:meta]),
                heart_rate: heart_rate_value(trkpt)
              )
            end
          end.flatten
        }
      end
    end

    def tag_data(trk, tag)
      tag = trk[:tags].find { |t| t[:tag] == tag }
      return nil unless tag

      tag[:data]
    end

    def refined_elevation(ele, meta)
      lat = meta[:lat].to_f
      lng = meta[:lon].to_f

      return ele unless lat && lng

      HgtReader.new.elevation(lat, lng)
    rescue StandardError => e
      @warnings << e.message unless warnings.include?(e.message)
      ele
    end

    def heart_rate_value(trkpt)
      extensions = trkpt[:tags].select { |t| t[:tag] == 'extensions' }.first
      return unless extensions

      ns3_extensions = extensions[:tags].select { |t| t[:tag] == 'ns3:TrackPointExtension' }.first
      return unless ns3_extensions

      from_tags(ns3_extensions, 'ns3:hr')&.to_i
    end

    def from_tags(tag, type)
      found = tag[:tags].select { |t| t[:tag] == type }
      return nil if found.empty?
      return found.first[:data] if found.length == 1

      found.map { |f| f[:data] }
    end

    def xml
      @xml ||= Parser::Xml.new(data: data).parse
    end
  end
end

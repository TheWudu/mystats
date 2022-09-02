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
    attr_reader :data, :warnings, :pause_threshold, :to_slow

    def initialize(data:)
      @data = data
      @warnings = []
      
      Geokit.default_units = :meters
    end

    def parse # rubocop:disable Metrics/AbcSize
      tracks.map do |track|
        enhanced_trace = enhance_trace(track[:points])
        set_thresholds(enhanced_trace)
        stats = calculate_stats(enhanced_trace)
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

    def enhance_trace(points)
      prev_point = points.first
      points[1..].each_with_object([]) do |cur_point, et|
        duration = cur_point[:time].to_f - prev_point[:time].to_f
        
        prev = Geokit::LatLng.new(prev_point[:lat].to_f, prev_point[:lon].to_f)
        cur  = Geokit::LatLng.new(cur_point[:lat].to_f, cur_point[:lon].to_f)
        distance = prev.distance_to(cur)
        
        speed = distance / duration / 1000 * 3600
        
        et << cur_point.merge(distance: distance, duration: duration, speed: speed)
        prev_point = cur_point
      end
    end

    def set_thresholds(points)
      # calculate average speed
      # and assume to slow is 1/10th of it
      avg_speed = points.sum { |p| p[:speed] } / points.size
      @to_slow = avg_speed / 10
ap "avg speed: #{avg_speed} -> to_slow: #{to_slow}"

      # get the average durations between the gps points
      # and remove the lower and upper 10% to remove the
      # superfast and the superslow points 
      # calculate the average time between the points
      # based on those 80% of the values.
      durations = points.map { |p| p[:duration] }.sort
      most_durations = durations[((points.size * 0.1).to_i)..((points.size*0.9).to_i)]

      # assume the pause has to have a duration > the average * 2
      @pause_threshold = most_durations.sum / most_durations.size * 2
ap "pause threshold: #{pause_threshold}"
    end

    def trace_from_track(track)
      track[:points].map do |p|
        {
          time: p[:time],
          lat:  p[:lat].to_f,
          lng:  p[:lon].to_f,
          ele:  p[:ele]
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

    def calculate_stats(points)
      stats = {
        elevation_gain: 0,
        elevation_loss: 0,
        distance:       0,
        pause:          0
      }

      prev_point = points.first
      points[1..].each do |cur_point|
        calc_pause(cur_point, stats)
        calc_elevation(cur_point, prev_point, stats)
        calc_distance(cur_point, stats)
        prev_point = cur_point
      end

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

    PAUSE_THRESHOLD = 10

    def calc_pause(cur_point, stats)
      if cur_point[:speed] < to_slow && cur_point[:duration] > pause_threshold
        stats[:pause] += cur_point[:duration]
      end
    end

    def calc_distance(cur_point, stats)
      stats[:distance] += cur_point[:distance]
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
                time: Time.parse(from_tags(trkpt, 'time')),
                ele:  refined_elevation(from_tags(trkpt, 'ele').to_f, trkpt[:meta])
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

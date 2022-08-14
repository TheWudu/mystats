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
    attr_reader :data, :errors

    def initialize(data:)
      @data = data
      @errors = []
    end

    def parse # rubocop:disable Metrics/AbcSize
      tracks.map do |track|
        stats = calculate_track(track)
        timezone = timezone_for(track[:points].first)
        duration = ((track[:points].last[:time] - track[:points].first[:time] - stats[:pause]) * 1000).to_i

        stats.merge({
                      id: SecureRandom.uuid,
                      notes: track[:name],
                      sport_type: track[:type],
                      sport_type_id: SportType.id_for(name: track[:type]),
                      start_time: track[:points].first[:time],
                      end_time: track[:points].last[:time],
                      duration: duration,
                      pause: (stats[:pause] * 1000).to_i,
                      timezone: timezone,
                      start_time_timezone_offset: timezone_offset(timezone, track[:points].first[:time]).to_i,
                      trace: trace_from_track(track)
                    })
      end
    end

    private

    def trace_from_track(track)
      track[:points].map do |p|
        {
          time: p[:time],
          lat: p[:lat].to_f,
          lng: p[:lon].to_f,
          ele: p[:ele]
        }
      end
    end

    def timezone_for(point)
      city = Repositories::Cities.nearest(lat: point[:lat].to_f, lng: point[:lon].to_f)
      return city[:timezone] if city

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
        distance: 0,
        pause: 0
      }

      prev_point = track[:points].first
      track[:points][1..].each do |cur_point|
        calc_pause(cur_point, prev_point, stats)
        calc_elevation(cur_point, prev_point, stats)
        calc_distance(cur_point, prev_point, stats)
        prev_point = cur_point
      end
ap stats

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
          name: tag_data(trk, 'name'),
          type: tag_data(trk, 'type'),
          points: trk[:tags].select { |t| t[:tag] == 'trkseg' }.map do |trkseg|
            trkseg[:tags].select { |t| t[:tag] == 'trkpt' }.map do |trkpt|
              trkpt[:meta].merge(
                time: Time.parse(from_tags(trkpt, 'time')),
                ele: refined_elevation(from_tags(trkpt, 'ele').to_f, trkpt[:meta])
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
      @errors << e
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

# data = File.read("/home/martin/coding/mongo_cpp/data/gpx/activity_8987491399.gpx")
# # data = File.read("test.gpx")
#
# ap Parser::Gpx.new(data: data).parse

# <?xml version="1.0" encoding="UTF-8"?>
# <gpx creator="Garmin Connect" version="1.1"
#   xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/11.xsd"
#   xmlns:ns3="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"
#   xmlns="http://www.topografix.com/GPX/1/1"
#   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="http://www.garmin.com/xmlschemas/GpxExtensions/v3">
#   <metadata>
#     <link href="connect.garmin.com">
#       <text>Garmin Connect</text>
#     </link>
#     <time>2022-06-10T05:39:43.000Z</time>
#   </metadata>
#   <trk>
#     <name>Quick short friday morning run.</name>
#     <type>running</type>
#     <trkseg>
#       <trkpt lat="47.98088229261338710784912109375" lon="13.15221391618251800537109375">
#         <ele>597.79998779296875</ele>
#         <time>2022-06-10T05:39:43.000Z</time>
#         <extensions>
#           <ns3:TrackPointExtension>
#             <ns3:hr>82</ns3:hr>
#             <ns3:cad>0</ns3:cad>
#           </ns3:TrackPointExtension>
#        </extensions>
#      </trkpt>
#    </trkseg>
#   </trk>
# </gpx>

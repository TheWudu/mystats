require "awesome_print"
require "time"
require "pry"
require "geokit"

require_relative "xml"


module Parser
  class Gpx

    attr_reader :data

    def initialize(data:)
      @data = data
    end

    def parse
      tracks.map do |track|
        stats = calculate_track(track)

        stats.merge({
          notes:       track[:name],
          sport_type:  track[:type],
          start_time:  track[:points].first[:time],
          end_time:    track[:points].last[:time],
          timezone:    nil,
          start_time_timezone_offset: nil,
        })
      end
    end

    private

    def calculate_track(track)
      Geokit::default_units = :meters

      stats = {
        elevation_gain: 0,
        elevation_loss: 0,
        distance:       0,
        duration:       0,
        pause:          0
      }

      prev_point = track[:points].first
      track[:points][1..-1].each do |cur_point|
        calc_elevation(cur_point, prev_point, stats)
        calc_distance(cur_point, prev_point, stats)
        calc_duration(cur_point, prev_point, stats)
        prev_point = cur_point
      end

      stats
    end

    def calc_elevation(cur_point, prev_point, stats)
      elevation = cur_point[:ele] - prev_point[:ele]
      if elevation < 0
        stats[:elevation_loss] += elevation.abs
      else
        stats[:elevation_gain] += elevation
      end
    end

    def calc_duration(cur_point, prev_point, stats)
      stats[:duration] += cur_point[:time].to_f - prev_point[:time].to_f
    end

    def calc_distance(cur_point, prev_point, stats)
      prev = Geokit::LatLng.new(prev_point[:lat].to_f, prev_point[:lon].to_f)
      cur  = Geokit::LatLng.new(cur_point[:lat].to_f, cur_point[:lon].to_f)
      stats[:distance] +=  prev.distance_to(cur)
    end

    def tracks
      gpx = xml.first
      @tracks ||= gpx[:tags].select { |t| t[:tag] == "trk" }.map do |trk| 
        { 
          name:   trk[:tags].find { |t| t[:tag] == "name" }[:data],
          type:   trk[:tags].find { |t| t[:tag] == "type" }[:data],
          points: trk[:tags].select { |t| t[:tag] == "trkseg" }.map do |trkseg| 
            trkseg[:tags].select { |t| t[:tag] == "trkpt" }.map do |trkpt| 
              trkpt[:meta].merge(
                time: Time.parse(from_tags(trkpt, "time")),
                ele:  from_tags(trkpt, "ele").to_f
              )
            end
          end.flatten
        }
      end
    end

    def from_tags(tag, type)
      found = tag[:tags].select { |t| t[:tag] == type }
      return nil if found.empty?
      return found.first[:data] if found.length == 1
      return found.map { |f| f[:data] }
    end

    def xml
      @xml ||= Parser::Xml.new(data: data).parse
    end
  end
end


data = File.read("/home/martin/coding/mongo_cpp/data/gpx/activity_8987491399.gpx")
# data = File.read("test.gpx")

ap Parser::Gpx.new(data: data).parse
 



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



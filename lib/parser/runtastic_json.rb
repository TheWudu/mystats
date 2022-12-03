# frozen_string_literal: true

require 'awesome_print'
require 'time'
require 'tzinfo'
require 'pry'
require 'geokit'
require_relative '../repositories/cities'
require 'sport_type'

require_relative 'xml'
require_relative 'gpx'

module Parser
  class RuntasticJson
    attr_reader :json_data, :gpx_data

    def initialize(json_data:, gpx_data:)
      @json_data = json_data
      @gpx_data  = gpx_data
    end

    def warnings
      gpx_parser&.warnings
    end

    DIRECT_JSON_ATTRIBUTES = %w[id notes duration pause].freeze

    def parse
      json_stats.slice(*DIRECT_JSON_ATTRIBUTES).merge(
        {
          sport_type:,
          start_time:,
          end_time:,
          start_time_timezone_offset:,
          timezone:,
          duration_up:,
          trace:
        }.merge(track_metrics)
      ).symbolize_keys.compact
    end

    def sport_type
      SportType.name_for_runtastic_id(id: json_stats['sport_type_id'].to_i)
    end

    def start_time
      Time.at(json_stats['start_time']  / 1000).utc
    end

    def end_time
      Time.at(json_stats['end_time'] / 1000).utc
    end

    def start_time_timezone_offset
      json_stats['start_time_timezone_offset'] / 1000
    end
    
    def end_time_timezone_offset
      json_stats['end_time_timezone_offset'] / 1000
    end

    def track_metrics
      feature = json_stats['features']&.find { |h| h['type'] == 'track_metrics' }
      return {} unless feature
      attrs = feature['attributes']

      {
        elevation_gain: attrs['elevation_gain'],
        elevation_loss: attrs['elevation_loss'],
        distance:       attrs['distance']
      }
    end

    def gpx_parser
      return nil  unless gpx_data

      @gpx_parser ||= Parser::Gpx.new(data: gpx_data)
    end

    def gpx_parsed
      return {} unless gpx_data

      @gpx_parsed ||= gpx_parser.parse.first
    rescue StandardError => e
      ap e.message
      ap e.backtrace if ENV['VERBOSE']
      {}
    end

    def trace
      gpx_parsed[:trace] || []
    end

    def timezone
      gpx_parsed[:timezone] || 'Europe/Vienna'
    end

    def duration_up
      gpx_parsed[:duration_up]
    end

    def json_stats
      @json_stats ||= JSON.parse(json_data)
    end
  end
end

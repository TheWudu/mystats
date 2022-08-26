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

    def parse
      {
        id:                         json_stats['id'],
        elevation_gain:             json_stats['elevation_gain'],
        elevation_loss:             json_stats['elevation_loss'],
        distance:                   json_stats['distance'],
        pause:                      json_stats['pause_duration'],
        notes:                      json_stats['notes'],
        sport_type:                 SportType.name_for_runtastic_id(id: json_stats['sport_type_id'].to_i),
        start_time:                 Time.at(json_stats['start_time'] / 1000),
        end_time:                   Time.at(json_stats['end_time'] / 1000),
        duration:                   json_stats['duration'],
        start_time_timezone_offset: json_stats['start_time_timezone_offset'] / 1000,
        timezone:                   timezone,
        trace:                      trace
      }.compact
    end

    def gpx_parsed
      return {} unless gpx_data

      @gpx_parsed ||= Parser::Gpx.new(data: gpx_data).parse.first
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

    def json_stats
      JSON.parse(json_data)
    end
  end
end

# frozen_string_literal: true

require 'definitions'

module Models
  class SportSession < Definition::Model
    required :id, Definition.Type(String)
    optional :sport_type, Definition.Type(String)
    required :start_time, Definition.Type(Time)
    required :end_time, Definition.Type(Time)
    required :timezone, Definition.Type(String)
    required :start_time_timezone_offset, Definition.Type(Integer)
    required :duration, Definition.Type(Integer)
    optional :duration_up, Definition.Type(Integer)
    optional :year, Definition.Type(Integer)
    optional :month, Definition.Type(Integer)
    optional :notes, Definition.Type(String)
    optional :distance, Definition.Type(Integer)
    optional :elevation_gain, Definition.Type(Integer)
    optional :elevation_loss, Definition.Type(Integer)
    optional :pause, Definition.Type(Integer)
    optional :heart_rate_max, Definition.Type(Integer)
    optional :heart_rate_avg, Definition.Type(Integer)
    optional :trace, Definition.Nilable(Definition.Each(Definitions::GpsPoint))

    def ==(other)
      other.as_json&.compact == as_json&.compact
    end

    def selector_text
      "#{start_time} - #{distance} - #{notes&.first(50)}"
    end

    def local_start_time
      start_time.in_time_zone(timezone)
    end

    def distance_in_km
      format_distance(distance)
    end

    def duration_as_str
      format_ms(duration)
    end

    def pause_as_str
      format_ms(pause)
    end

    def elevation
      format_elevation(elevation_gain, elevation_loss)
    end

    # [m/h]
    def vam
      return unless duration_up

      (elevation_gain.to_f / (duration_up / 1000.0) * 3600).round(2)
    end

    def avg_pace
      return '-' if distance.nil? || distance.zero?

      format_ms(duration / distance * 1000)
    end

    def format_ms(millis)
      secs, = millis.divmod(1000) # divmod returns [quotient, modulus]
      mins, secs = secs.divmod(60)
      hours, mins = mins.divmod(60)
      hours = nil if hours.zero?

      [hours, mins, secs].compact.map { |e| e.to_s.rjust(2, '0') }.join ':'
    end

    def format_distance(distance)
      return '-' if !distance || distance.zero?

      (distance / 1000.0).round(2)
    end

    def format_elevation(gain, loss)
      return '-' unless gain || loss
      return '-' if gain.zero? && loss.zero?

      "#{gain} / #{loss}"
    end
  end
end

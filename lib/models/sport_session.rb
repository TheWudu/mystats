# frozen_string_literal: true

module Models
  class SportSession
    attr_accessor :id, :notes,
                  :distance, :trace, :duration, :start_time, :end_time, :timezone, :start_time_timezone_offset,
                  :year, :month,
                  :elevation_gain, :elevation_loss, :sport_type_id,
                  :pause, :sport_type

    def initialize(attrs = {})
      attrs.each do |k, v|
        send("#{k}=", v)
      end
    end

    def selector_text
      "#{start_time} - #{distance} - #{notes&.first(50)}"
    end

    def local_start_time
      start_time.in_time_zone(timezone)
    end

    def sport
      SportType.name_for(id: sport_type_id)
    end

    def distance_in_km
      format_distance(distance)
    end

    def duration_as_str
      format_ms(duration)
    end

    def elevation
      format_elevation(elevation_gain, elevation_loss)
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

# frozen_string_literal: true

module Models
  class Course
    attr_accessor :id, :name, :distance, :trace, :session_ids

    def initialize(attrs = {})
      attrs.each do |k, v|
        send("#{k}=", v)
      end
    end

    def to_h
      {
        id: id,
        name: name,
        distance: distance,
        session_ids: session_ids,
        trace: trace
      }
    end

    def ==(other)
      other&.as_json == self&.as_json
    end
  end
end

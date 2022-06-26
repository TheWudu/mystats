# frozen_string_literal: true

module Parser
  class Geonames
    attr_accessor :cities

    def run
      self.cities = parse(filename)
      cities.count
    end

    def parse(filename)
      cities = []

      File.readlines(filename).each do |line|
        cities << parse_line(line)
      end

      cities
    end

    def parse_line(line)
      entry = line.split("\t")
      {
        name: entry[1],
        latitude: entry[4].to_f,
        longitude: entry[5].to_f,
        timezone: entry[17]
      }
    end

    def filename
      File.join(Rails.root, 'public/cities500.txt')
    end
  end
end

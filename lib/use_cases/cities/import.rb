# frozen_string_literal: true

require 'parser/gpx'

module UseCases
  module Cities
    class Import
      attr_reader :cities, :filename

      def initialize(filename:)
        @filename = filename
      end

      def run
        create_indexes

        result = with_progress do |bar|
          File.readlines(filename).each_with_object([]) do |line, ary|
            bar.increment
            city = line_to_city(line)

            ary << store_if_not_exist(city)
          end
        end

        puts "Inserted #{result.count(true)}, skipped #{result.count(false)}"
      end

      def store_if_not_exist(city)
        return false if exist?(city)

        !!store(city)
      end

      def line_to_city(line)
        parts = line.split("\t")
        {
          name: parts[1],
          timezone: parts[17],
          latitude: parts[4].to_f,
          longitude: parts[5].to_f
        }
      end

      def line_count
        `wc -l "#{filename}"`.strip.split(' ')[0].to_i
      end

      def exist?(city)
        repo.exist?(name: city[:name])
      end

      def store(city)
        repo.insert(city: city)
      end

      def create_indexes
        repo.create_geo_index
        repo.create_name_index
      end

      def repo
        Repositories::Cities
      end

      def with_progress
        bar = ProgressBar.create(title: 'Items', total: line_count, format: "%c/%C (%j \%) - %e - %B")
        yield bar
      end
    end
  end
end

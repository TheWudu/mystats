# frozen_string_literal: true

require 'parser/gpx'
require_relative 'import_multiple'

module UseCases
  module Session
    class ImportGpxFolder < ImportMultiple

      private

      def filenames
        @filenames ||= Dir.glob(File.join(path, '*.gpx')).map do |filename|
          filename
        end
      end

      def read_files
        with_progress do |bar|
          filenames.map do |filename|
            gpx_data = File.read(filename)
            bar.increment
            parse(gpx_data)
          end.flatten
        end
      end

      def parse(gpx_data)
        parser = Parser::Gpx.new(data: gpx_data)
        parser.parse
      end

    end
  end
end

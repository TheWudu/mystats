# frozen_string_literal: true

require 'parser/runtastic_json'
require_relative 'import_multiple'

module UseCases
  module Session
    class ImportRuntasticExport < ImportMultiple

      private

      def filenames
        @filenames ||= Dir.glob(File.join(path, '*.json')).map do |filename|
          filename.split('/').last.split('.').first
        end
      end

      def read_files
        with_progress do |bar|
          filenames.map do |filename|
            json_data = File.read(File.join(path, "#{filename}.json"))
            gpx_data  = begin
              File.read(File.join(path, 'GPS-data', "#{filename}.gpx"))
            rescue StandardError
              nil
            end
            bar.increment
            parse(json_data, gpx_data)
          end
        end
      end

      def parse(json_data, gpx_data)
        parser = Parser::RuntasticJson.new(json_data: json_data, gpx_data: gpx_data)
        parser.parse
      end

    end
  end
end

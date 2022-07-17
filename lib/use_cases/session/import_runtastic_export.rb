require "parser/runtastic_json"
require_relative "import"

module UseCases
  module Session
    class ImportRuntasticExport < Import
    
      attr_reader :path

      def initialize(path:)
        @path = path
      end

      def run
        puts "Read and parse #{filenames.count} files"
        sport_sessions = read_files
        puts "Store #{sport_sessions.count} sport sessions"
        store_sessions(sport_sessions)
      end

      def store_sessions(sport_sessions)
        with_progress do |bar|
          sport_sessions.each do |sport_session|
            store(sport_session)
            bar.increment
          end
        end
      end

      private

      def filenames
        @filenames ||= Dir.glob(File.join(path, "*.json")).map do |filename|
          filename.split("/").last.split(".").first
        end
      end
        
      def read_files
        with_progress do |bar|
          filenames.map do |filename|
            json_data = File.read(File.join(path, "#{filename}.json"))
            gpx_data  = File.read(File.join(path, "GPS-data", "#{filename}.gpx")) rescue nil
            bar.increment
            parse(json_data, gpx_data)
          end
        end
      end

      def parse(json_data, gpx_data)
        parser = Parser::RuntasticJson.new(json_data: json_data, gpx_data: gpx_data)
        parser.parse
      end

      def with_progress
        bar = ProgressBar.create(:title => "Items", :total => filenames.size, format: "%c/%C (%j \%) - %e - %B")
        yield bar
      end
    end
  end
end

# frozen_string_literal: true

require_relative 'import'

module UseCases
  module Session
    class ImportMultiple < Import
      attr_reader :path

      def initialize(path:)
        super()
        @path = path
      end

      def run
        return unless check_cities_imported

        puts "Read and parse #{filenames.count} files"
        sport_sessions = read_files
        puts "Store #{sport_sessions.count} sport sessions"
        result = store_sessions(sport_sessions)
        puts "Inserted #{result.count(:inserted)}, updated #{result.count(:updated)}, failed #{result.count(:failed)}"
      end

      def store_sessions(sport_sessions)
        with_progress do |bar|
          sport_sessions.each_with_object([]) do |sport_session, ary|
            ary << store(sport_session)
            bar.increment
          end
        end
      end

      def with_progress
        bar = ProgressBar.create(title: 'Items', total: filenames.size, format: "%c/%C (%j \%) - %e - %B")
        yield bar
      end

      def check_cities_imported
        return true if Repositories::Cities.count.positive?

        puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        puts 'Cities not imported, timezone related information might be wrong'
        puts 'Use:'
        puts '  rake import:cities[filename]'
        puts 'to import'
        puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'

        puts 'Continue? [yN] '
        $stdin.gets.chomp == 'y'
      end
    end
  end
end

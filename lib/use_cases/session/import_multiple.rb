# frozen_string_literal: true

require_relative 'import'

module UseCases
  module Session
    class ImportMultiple < Import
      
      attr_reader :path

      def initialize(path:)
        @path = path
      end

      def run
        puts "Read and parse #{filenames.count} files"
        sport_sessions = read_files
        puts "Store #{sport_sessions.count} sport sessions"
        result = store_sessions(sport_sessions)
        puts "Inserted #{result.count(true)}, skipped #{result.count(false)}"
      end
      
      def store_sessions(sport_sessions)
        with_progress do |bar|
          sport_sessions.each_with_object([]) do |sport_session, ary|
            ary << !!store(sport_session)
            bar.increment
          end
        end
      end
      
      def with_progress
        bar = ProgressBar.create(title: 'Items', total: filenames.size, format: "%c/%C (%j \%) - %e - %B")
        yield bar
      end

    end
  end
end

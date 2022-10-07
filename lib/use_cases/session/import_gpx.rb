# frozen_string_literal: true

require 'parser/gpx'
require_relative 'import'

module UseCases
  module Session
    class ImportGpx < Import
      attr_reader :data, :warns

      def initialize(data:)
        super()
        @data = data
        @warns = []
      end

      def run
        sessions.each do |session|
          inserted = store(session)
          add_warning('already exists') unless inserted
        end
      end

      def errors
        []
      end

      def warnings
        parser.warnings +
          warns
      end

      def count
        sessions.count
      end

      private

      def add_warning(txt)
        warns << txt
      end

      def sessions
        @sessions ||= parser.parse
      end

      def parser
        @parser ||= Parser::Gpx.new(data:)
      end
    end
  end
end

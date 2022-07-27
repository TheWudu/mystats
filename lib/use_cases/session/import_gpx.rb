# frozen_string_literal: true

require 'parser/gpx'
require_relative 'import'

module UseCases
  module Session
    class ImportGpx < Import
      attr_reader :data

      def initialize(data:)
        super()
        @data = data
      end

      def run
        sessions.each do |session|
          store(session)
        end
      end

      def errors
        parser.errors
      end

      private

      def sessions
        parser.parse
      end
      
      def parser
        @parser ||= Parser::Gpx.new(data: data)
      end
    end
  end
end

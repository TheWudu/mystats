# frozen_string_literal: true

require 'parser/gpx'
require_relative 'import'

module UseCases
  module Session
    class ImportGpx < Import
      attr_reader :data

      def initialize(data:)
        @data = data
      end

      def run
        sessions.each do |session|
          store(session)
        end
      end

      private

      def sessions
        Parser::Gpx.new(data: data).parse
      end
    end
  end
end

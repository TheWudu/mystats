# frozen_string_literal: true

require 'parser/gpx'
require_relative 'import'

module UseCases
  module Session
    class ImportFile < Import
      attr_reader :data, :type, :warns

      def initialize(data:, type:)
        super()
        @data = data
        @type = type
        @warns = []
      end

      def run
        sessions.each do |session|
          action = store(session)
          add_warning('already exists - updated') if action == :updated
          add_error('can not store') if action == :failed
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

      def add_error(txt)
        errors << txt
      end

      def add_warning(txt)
        warns << txt
      end

      def sessions
        @sessions ||= parser.parse
      end

      def parser
        @parser ||= case type 
          when "gpx"
            Parser::Gpx.new(data: data)
          when "fit"
            Parser::Fit.new(data: data) 
          else
            raise "Unknown type" 
          end
      end
    end
  end
end

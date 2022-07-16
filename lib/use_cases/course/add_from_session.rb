# frozen_string_literal: true

module UseCases
  module Course
    class AddFromSession
      attr_reader :session, :name

      def initialize(session:, name:)
        @session = session
        @name    = name
      end

      def run
        Repositories::Courses.insert(course: course)
      end

      def course
        Models::Course.new(
          id: SecureRandom.uuid,
          name: name,
          trace: trace,
          distance: session.distance,
          session_ids: [session.id]
        )
      end

      def trace
        session.trace.map { |p| p.slice('lat', 'lng', 'ele') }
      end
    end
  end
end

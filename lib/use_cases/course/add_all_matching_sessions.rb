# frozen_string_literal: true

module UseCases
  module Course
    class AddAllMatchingSessions
      attr_reader :course_id

      def initialize(course_id:)
        @course_id = course_id
      end

      def run
        ids = matching_sessions.map(&:id)
        new_ids = (course.session_ids + ids).uniq.compact
        update_course(new_ids)
      end

      private

      def matching_sessions
        distance = course.distance
        sessions = Repositories::SportSessions.where(opts: {
                                                       'distance.between' => [distance - 250, distance + 250],
                                                       'id.not_in'        => course.session_ids,
                                                       'trace.exists'     => true
                                                     })
        sessions.each_with_object([]) do |session, ary|
          matcher = UseCases::Traces::Matcher.new(trace1: course.trace, trace2: session.trace)
          matcher.analyse
          ary << session if matcher.matching?
        end.compact
      end

      def course
        @course ||= Repositories::Courses.find(id: course_id)
      end

      def update_course(new_ids)
        updated_course = course.class.new(course.merge(session_ids: new_ids))
        Repositories::Courses.update(course: updated_course)
      end
    end
  end
end

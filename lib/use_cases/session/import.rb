require "parser/gpx"

module UseCases
  module Session
    class Import

      attr_reader :data

      def initialize(data:)
        @data = data
      end

      def run
        sessions.each do |session|
ap session
          next if exists?(session)
          store(session)
        end
      end

      private

      def sessions
        @sessions ||= Parser::Gpx.new(data: data).parse.map do |session|
          session[:id] = SecureRandom.uuid
          session
        end
      end

      def store(session)
ap "store #{session}"
        session_repo.insert(session: session)
      end

      def exists?(session)
        !!session_repo.find(start_time: session[:start_time], sport_type_id: session[:sport_type_id])
      end

      def session_repo
        Repositories::Sessions::MongoDb.new
      end
    end
  end
end

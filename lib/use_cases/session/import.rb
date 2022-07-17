require "repositories/sport_sessions"

module UseCases
  module Session
    class Import
      
      def store(session)
        return false if exists?(session)
        session_repo.insert(session: session)
      end

      def exists?(session)
        session_repo.exists?(
          start_time: session[:start_time],
          sport_type_id: session[:sport_type_id]
        )
      end

      def session_repo
        Repositories::SportSessions
      end
    end
  end
end

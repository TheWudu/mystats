# frozen_string_literal: true

require 'repositories/sport_sessions'

module UseCases
  module Session
    class Import
      def store(session_hash)
        if exists?(session_hash)
          update(session_hash)
        else
          insert(session_hash)
        end
      end

      def update(session_hash)
        if session_repo.update(session_hash:)
          :updated
        else
          :failed
        end
      end

      def insert(session_hash)
        if session_repo.insert(session_hash:)
          :inserted
        else
          :failed
        end
      end

      def exists?(session_hash)
        session_repo.exists?(
          start_time: session_hash[:start_time],
          sport_type: session_hash[:sport_type]
        )
      end

      def session_repo
        Repositories::SportSessions
      end
    end
  end
end

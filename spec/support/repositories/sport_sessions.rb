# frozen_string_literal: true

require 'connections/mongo_db'

module Repositories
  module SportSessions
    class MongoDb
      def clear
        return unless Rails.env.test?

        collection.delete_many({})
      end
    end

    def self.clear
      strategy_instance.clear
    end
  end
end

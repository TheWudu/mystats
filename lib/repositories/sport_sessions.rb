module Repositories
  module SportSessions

    %w[fetch
      find
      find_by_id
      find_by_ids
      where 
      find_with_traces 
      exists?
      insert].each do |method_name| 
      define_singleton_method(method_name) do |**args|
        strategy.public_send(method_name, **args)
      end
    end

    def self.strategy
      MongoDb.new
    end

  end
end

require_relative "sport_sessions/mongo_db"

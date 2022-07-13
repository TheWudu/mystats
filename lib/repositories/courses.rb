module Repositories
  module Courses 

    %w[fetch
      find
      insert
      update
      session_ids
      delete].each do |method_name| 
      define_singleton_method(method_name) do |**args|
        strategy.public_send(method_name, **args)
      end
    end

    def self.strategy
      MongoDb.new
    end

  end
end

require_relative "courses/mongo_db"

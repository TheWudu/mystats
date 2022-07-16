module Repositories
  module Cities

    %w[fetch
      nearest 
      exist?
      insert
      create_geo_index 
      create_name_index].each do |method_name| 
      define_singleton_method(method_name) do |**args|
        strategy.public_send(method_name, **args)
      end
    end

    def self.strategy
      MongoDb.new
    end

  end
end

require_relative "cities/mongo_db"

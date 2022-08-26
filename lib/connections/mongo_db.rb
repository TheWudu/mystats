# frozen_string_literal: true

require 'mongo'

module Connections
  class MongoDb
    def self.connection
      @connection ||= ::Mongo::Client.new(["#{db_host}:#{db_port}"], database: db_name).database
    end
    
    def self.db_host
      ENV.fetch("MONGODB_HOST", "127.0.0.1")
    end

    def self.db_port
      ENV.fetch("MONGODB_PORT", "27017")
    end

    def self.db_name
      suffix = '_test' if Rails.env.test?
      "mydb#{suffix}"
    end
  end
end

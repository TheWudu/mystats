# frozen_string_literal: true

require 'mongo'

module Connections
  class MongoDb
    def self.connection
      @connection ||= ::Mongo::Client.new(['127.0.0.1:27017'], database: db_name).database
    end

    def self.db_name
      suffix = '_test' if Rails.env.test?
      "mydb#{suffix}"
    end
  end
end

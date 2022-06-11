module Connections
  class MongoDb
    def self.connection
      @mongo ||= ::Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mydb').database
    end
  end
end

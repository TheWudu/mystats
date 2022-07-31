require "mongo"

Mongo::Logger.logger = Rails.logger
Mongo::Logger.level == Logger::DEBUG

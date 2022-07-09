# frozen_string_literal: true

require 'connections/mongo_db'

module Repositories
  module Courses
    class MongoDb
      def fetch
        collection.find({}).sort({ name: 1 }).to_a
      end

      def find(id:)
        collection.find({ id: id }).first
      end

      def insert(course:)
        collection.insert_one(prepare_for_write(course))
      end

      private

      def prepare_for_write(course)
        course.id ||= SecureRandom.uuid
        course.to_h
      end

      def collection
        @collection ||= Connections::MongoDb.connection[:courses]
      end
    end
  end
end

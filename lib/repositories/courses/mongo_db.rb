# frozen_string_literal: true

require 'connections/mongo_db'

module Repositories
  module Courses
    class MongoDb
      def fetch
        collection.find({}).sort({ name: 1 }).map do |doc|
          to_model(doc)
        end
      end

      def find(id:)
        doc = collection.find({ id: id }).first
        to_model(doc)
      end

      def insert(course:)
        collection.insert_one(prepare_for_write(course))
      end

      def update(course:)
        collection.find(id: course.id).update_one(prepare_for_write(course))
      end

      def session_ids
        collection.aggregate([
                               { '$unwind' => '$session_ids' },
                               { '$project' => { _id: '$session_ids' } }
                             ]).map do |doc|
          doc['_id']
        end
      end

      def delete(id:)
        collection.find({ id: id }).delete_one
      end

      private

      def to_model(doc)
        attrs = doc.except('_id')
        Models::Course.new(attrs)
      end

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

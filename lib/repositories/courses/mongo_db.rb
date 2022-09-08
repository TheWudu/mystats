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
        return nil unless doc

        to_model(doc)
      end

      def find_by_distance(distance__gte:, distance__lte:)
        docs = collection.find({
                                 "distance": {
                                   "$gte": distance__gte,
                                   "$lte": distance__lte
                                 }
                               })
        docs.map do |doc|
          to_model(doc)
        end
      end

      def find_by_session_id(id:)
        doc = collection.find({ "session_ids": id }).first
        return nil unless doc

        to_model(doc)
      end

      def insert(course:)
        resp = collection.insert_one(prepare_for_write(course))
        resp.n == 1
      end

      def update(course:)
        resp = collection.find(id: course.id).update_one(prepare_for_write(course))
        resp.n == 1
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
        resp = collection.find({ id: id }).delete_one
        resp.n == 1
      end

      private

      def to_model(doc)
        attrs = doc.except('_id').symbolize_keys
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

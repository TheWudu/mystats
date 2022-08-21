require_relative 'mongo_db'

module Repositories
  module SportSessions
    class Where < MongoDb
      # distance.between
      # id.not_in
      # trace.exists
      # year
      # month
      # sport_type_id

      IN_LIST_MATCHER = %w[year month sport_type_id].freeze
      NOT_IN_LIST_MATCHER = %w[id].freeze
      EXISTS_MATCHER = %w[trace].freeze
      RANGE_MATCHER = %w[distance].freeze
      def execute(args)
        query = {}
        query.merge!(in_list_matcher(args))
        query.merge!(not_in_list_matcher(args))
        query.merge!(exists_matcher(args))
        query.merge!(range_matcher(args))

        collection.find(query).map do |session|
          to_model(session)
        end
      end

      def in_list_matcher(args)
        IN_LIST_MATCHER.each_with_object({}) do |attr, q|
          value = args[attr] || args[attr.to_sym]
          next unless value

          q[attr] = { '$in' => value }
        end
      end

      def not_in_list_matcher(args)
        NOT_IN_LIST_MATCHER.each_with_object({}) do |attr, q|
          value = args["#{attr}.not_in"]
          next unless value

          q[attr] = { '$nin' => value }
        end
      end

      def exists_matcher(args)
        EXISTS_MATCHER.each_with_object({}) do |attr, q|
          value = args["#{attr}.exists"]
          next unless value

          q[attr] = { '$exists' => true }
        end
      end

      def range_matcher(args)
        RANGE_MATCHER.each_with_object({}) do |attr, q|
          value = args["#{attr}.between"]
          next unless value

          q[attr] = { '$gte' => value.first, '$lte' => value.second }
        end
      end

    end
  end
end

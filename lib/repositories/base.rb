# frozen_string_literal: true

module Repositories
  module Base
    def create_methods(methods)
      methods.each do |method_name|
        define_singleton_method(method_name) do |**args|
          strategy_instance.public_send(method_name, **args)
        end
      end
    end

    def setup_strategy(strategy)
      @strategy ||= strategy # rubocop:disable Naming/MemoizedInstanceVariableName
    end

    def strategy_instance
      @strategy.new
    end
  end
end

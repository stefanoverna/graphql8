# frozen_string_literal: true
# test_via: ../subscriptions.rb
module GraphQL8
  class Subscriptions
    # This thing can be:
    # - Subscribed to by `subscription { ... }`
    # - Triggered by `MySchema.subscriber.trigger(name, arguments, obj)`
    #
    # An array of `Event`s are passed to `store.register(query, events)`.
    class Event
      # @return [String] Corresponds to the Subscription root field name
      attr_reader :name

      # @return [GraphQL8::Query::Arguments]
      attr_reader :arguments

      # @return [GraphQL8::Query::Context]
      attr_reader :context

      # @return [String] An opaque string which identifies this event, derived from `name` and `arguments`
      attr_reader :topic

      def initialize(name:, arguments:, field: nil, context: nil, scope: nil)
        @name = name
        @arguments = arguments
        @context = context
        field ||= context.field
        scope_val = scope || (context && field.subscription_scope && context[field.subscription_scope])

        @topic = self.class.serialize(name, arguments, field, scope: scope_val)
      end

      # @return [String] an identifier for this unit of subscription
      def self.serialize(name, arguments, field, scope:)
        normalized_args = case arguments
        when GraphQL8::Query::Arguments
          arguments
        when Hash
          GraphQL8::Query::LiteralInput.from_arguments(
            arguments,
            field,
            nil,
          )
        else
          raise ArgumentError, "Unexpected arguments: #{arguments}, must be Hash or GraphQL8::Arguments"
        end

        sorted_h = normalized_args.to_h.sort.to_h
        Serialize.dump_recursive([scope, name, sorted_h])
      end
    end
  end
end

# frozen_string_literal: true
module GraphQL8
  module Relay
    # Mixin for Relay-related methods in type objects
    # (used by BaseType and Schema::Member).
    module TypeExtensions
      # @return [GraphQL8::ObjectType] The default connection type for this object type
      def connection_type
        @connection_type ||= define_connection
      end

      # Define a custom connection type for this object type
      # @return [GraphQL8::ObjectType]
      def define_connection(**kwargs, &block)
        GraphQL8::Relay::ConnectionType.create_type(self, **kwargs, &block)
      end

      # @return [GraphQL8::ObjectType] The default edge type for this object type
      def edge_type
        @edge_type ||= define_edge
      end

      # Define a custom edge type for this object type
      # @return [GraphQL8::ObjectType]
      def define_edge(**kwargs, &block)
        GraphQL8::Relay::EdgeType.create_type(self, **kwargs, &block)
      end
    end
  end
end

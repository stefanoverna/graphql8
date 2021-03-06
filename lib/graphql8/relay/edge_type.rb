# frozen_string_literal: true
module GraphQL8
  module Relay
    module EdgeType
      def self.create_type(wrapped_type, name: nil, &block)
        GraphQL8::ObjectType.define do
          type_name = wrapped_type.is_a?(GraphQL8::BaseType) ? wrapped_type.name : wrapped_type.graphql_name
          name("#{type_name}Edge")
          description "An edge in a connection."
          field :node, wrapped_type, "The item at the end of the edge."
          field :cursor, !types.String, "A cursor for use in pagination."
          relay_node_type(wrapped_type)
          block && instance_eval(&block)
        end
      end
    end
  end
end

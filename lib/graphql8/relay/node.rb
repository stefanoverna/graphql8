# frozen_string_literal: true
module GraphQL8
  module Relay
    # Helpers for working with Relay-specific Node objects.
    module Node
      # @return [GraphQL8::Field] a field for finding objects by their global ID.
      def self.field(**kwargs, &block)
        # We have to define it fresh each time because
        # its name will be modified and its description
        # _may_ be modified.
        field = GraphQL8::Field.define do
          type(GraphQL8::Relay::Node.interface)
          description("Fetches an object given its ID.")
          argument(:id, types.ID.to_non_null_type, "ID of the object.")
          resolve(GraphQL8::Relay::Node::FindNode)
          relay_node_field(true)
        end

        if kwargs.any? || block
          field = field.redefine(kwargs, &block)
        end

        field
      end

      def self.plural_field(**kwargs, &block)
        field = GraphQL8::Field.define do
          type(!types[GraphQL8::Relay::Node.interface])
          description("Fetches a list of objects given a list of IDs.")
          argument(:ids, types.ID.to_non_null_type.to_list_type.to_non_null_type, "IDs of the objects.")
          resolve(GraphQL8::Relay::Node::FindNodes)
          relay_nodes_field(true)
        end

        if kwargs.any? || block
          field = field.redefine(kwargs, &block)
        end

        field
      end

      # @return [GraphQL8::InterfaceType] The interface which all Relay types must implement
      def self.interface
        @interface ||= GraphQL8::Types::Relay::Node.graphql_definition
      end

      # A field resolve for finding objects by IDs
      module FindNodes
        def self.call(obj, args, ctx)
          args[:ids].map { |id| ctx.query.schema.object_from_id(id, ctx) }
        end
      end

      # A field resolve for finding an object by ID
      module FindNode
        def self.call(obj, args, ctx)
          ctx.query.schema.object_from_id(args[:id], ctx )
        end
      end
    end
  end
end

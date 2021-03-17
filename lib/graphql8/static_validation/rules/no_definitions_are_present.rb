# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    class NoDefinitionsArePresent
      include GraphQL8::StaticValidation::Message::MessageHelper

      def validate(context)
        schema_definition_nodes = []
        register_node = ->(node, _p) {
          schema_definition_nodes << node
          GraphQL8::Language::Visitor::SKIP
        }

        visitor = context.visitor

        visitor[GraphQL8::Language::Nodes::DirectiveDefinition] << register_node
        visitor[GraphQL8::Language::Nodes::SchemaDefinition] << register_node
        visitor[GraphQL8::Language::Nodes::ScalarTypeDefinition] << register_node
        visitor[GraphQL8::Language::Nodes::ObjectTypeDefinition] << register_node
        visitor[GraphQL8::Language::Nodes::InputObjectTypeDefinition] << register_node
        visitor[GraphQL8::Language::Nodes::InterfaceTypeDefinition] << register_node
        visitor[GraphQL8::Language::Nodes::UnionTypeDefinition] << register_node
        visitor[GraphQL8::Language::Nodes::EnumTypeDefinition] << register_node

        visitor[GraphQL8::Language::Nodes::SchemaExtension] << register_node
        visitor[GraphQL8::Language::Nodes::ScalarTypeExtension] << register_node
        visitor[GraphQL8::Language::Nodes::ObjectTypeExtension] << register_node
        visitor[GraphQL8::Language::Nodes::InputObjectTypeExtension] << register_node
        visitor[GraphQL8::Language::Nodes::InterfaceTypeExtension] << register_node
        visitor[GraphQL8::Language::Nodes::UnionTypeExtension] << register_node
        visitor[GraphQL8::Language::Nodes::EnumTypeExtension] << register_node

        visitor[GraphQL8::Language::Nodes::Document].leave << ->(node, _p) {
          if schema_definition_nodes.any?
            context.errors << message(%|Query cannot contain schema definitions|, schema_definition_nodes, context: context)
          end
        }
      end
    end
  end
end

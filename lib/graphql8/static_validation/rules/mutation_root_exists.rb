# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    class MutationRootExists
      include GraphQL8::StaticValidation::Message::MessageHelper

      def validate(context)
        return if context.warden.root_type_for_operation("mutation")

        visitor = context.visitor

        visitor[GraphQL8::Language::Nodes::OperationDefinition].enter << ->(ast_node, prev_ast_node) {
          if ast_node.operation_type == 'mutation'
            context.errors << message('Schema is not configured for mutations', ast_node, context: context)
            return GraphQL8::Language::Visitor::SKIP
          end
        }
      end
    end
  end
end

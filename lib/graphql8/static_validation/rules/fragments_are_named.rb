# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    class FragmentsAreNamed
      include GraphQL8::StaticValidation::Message::MessageHelper

      def validate(context)
        context.visitor[GraphQL8::Language::Nodes::FragmentDefinition] << ->(node, parent) { validate_name_exists(node, context) }
      end

      private

      def validate_name_exists(node, context)
        if node.name.nil?
          context.errors << message("Fragment definition has no name", node, context: context)
        end
      end
    end
  end
end

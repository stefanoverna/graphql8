# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    class FragmentNamesAreUnique
      include GraphQL8::StaticValidation::Message::MessageHelper

      def validate(context)
        fragments_by_name = Hash.new { |h, k| h[k] = [] }
        context.visitor[GraphQL8::Language::Nodes::FragmentDefinition] << ->(node, parent) {
          fragments_by_name[node.name] << node
        }

        context.visitor[GraphQL8::Language::Nodes::Document].leave << ->(node, parent) {
          fragments_by_name.each do |name, fragments|
            if fragments.length > 1
              context.errors << message(%|Fragment name "#{name}" must be unique|, fragments, context: context)
            end
          end
        }
      end
    end
  end
end

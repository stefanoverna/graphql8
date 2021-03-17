# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    # Implement validate_node
    class ArgumentsValidator
      module ArgumentsValidatorHelpers
        private

        def parent_name(parent, type_defn)
          if parent.is_a?(GraphQL8::Language::Nodes::Field)
            parent.alias || parent.name
          elsif parent.is_a?(GraphQL8::Language::Nodes::InputObject)
            type_defn.name
          else
            parent.name
          end
        end

        def node_type(parent)
          parent.class.name.split("::").last
        end
      end

      include ArgumentsValidatorHelpers
      include GraphQL8::StaticValidation::Message::MessageHelper

      def validate(context)
        visitor = context.visitor
        visitor[GraphQL8::Language::Nodes::Argument] << ->(node, parent) {
          case parent
          when GraphQL8::Language::Nodes::InputObject
            arg_defn = context.argument_definition
            if arg_defn.nil?
              return
            else
              parent_defn = arg_defn.type.unwrap
              if !parent_defn.is_a?(GraphQL8::InputObjectType)
                return
              end
            end
          when GraphQL8::Language::Nodes::Directive
            parent_defn = context.schema.directives[parent.name]
          when GraphQL8::Language::Nodes::Field
            parent_defn = context.field_definition
          else
            raise "Unexpected argument parent: #{parent.class} (##{parent})"
          end
          validate_node(parent, node, parent_defn, context)
        }
      end
    end

  end
end

# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    class VariableDefaultValuesAreCorrectlyTyped
      include GraphQL8::StaticValidation::Message::MessageHelper

      def validate(context)
        context.visitor[GraphQL8::Language::Nodes::VariableDefinition] << ->(node, parent) {
          if !node.default_value.nil?
            validate_default_value(node, context)
          end
        }
      end

      def validate_default_value(node, context)
        value = node.default_value
        if node.type.is_a?(GraphQL8::Language::Nodes::NonNullType)
          context.errors << message("Non-null variable $#{node.name} can't have a default value", node, context: context)
        else
          type = context.schema.type_from_ast(node.type)
          if type.nil?
            # This is handled by another validator
          else
            begin
              valid = context.valid_literal?(value, type)
            rescue GraphQL8::CoercionError => err
              error_message = err.message
            rescue GraphQL8::LiteralValidationError
              # noop, we just want to stop any LiteralValidationError from propagating
            end

            if !valid
              error_message ||= "Default value for $#{node.name} doesn't match type #{type}"
              context.errors << message(error_message, node, context: context)
            end
          end
        end
      end
    end
  end
end

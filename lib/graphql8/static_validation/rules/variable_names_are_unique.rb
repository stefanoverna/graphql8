# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    class VariableNamesAreUnique
      include GraphQL8::StaticValidation::Message::MessageHelper

      def validate(context)
        context.visitor[GraphQL8::Language::Nodes::OperationDefinition] << ->(node, parent) {
          var_defns = node.variables
          if var_defns.any?
            vars_by_name = Hash.new { |h, k| h[k] = [] }
            var_defns.each { |v| vars_by_name[v.name] << v }
            vars_by_name.each do |name, defns|
              if defns.size > 1
                context.errors << message("There can only be one variable named \"#{name}\"", defns, context: context)
              end
            end
          end
        }
      end
    end
  end
end

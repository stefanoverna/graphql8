# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    class FieldsWillMerge
      # Special handling for fields without arguments
      NO_ARGS = {}.freeze

      def validate(context)
        context.each_irep_node do |node|
          if node.ast_nodes.size > 1
            defn_names = Set.new(node.ast_nodes.map(&:name))

            # Check for more than one GraphQL8::Field backing this node:
            if defn_names.size > 1
              defn_names = defn_names.sort.join(" or ")
              msg = "Field '#{node.name}' has a field conflict: #{defn_names}?"
              context.errors << GraphQL8::StaticValidation::Message.new(msg, nodes: node.ast_nodes.to_a)
            end

            # Check for incompatible / non-identical arguments on this node:
            args = node.ast_nodes.map do |n|
              if n.arguments.any?
                n.arguments.reduce({}) do |memo, a|
                  arg_value = a.value
                  memo[a.name] = case arg_value
                  when GraphQL8::Language::Nodes::AbstractNode
                    arg_value.to_query_string
                  else
                    GraphQL8::Language.serialize(arg_value)
                  end
                  memo
                end
              else
                NO_ARGS
              end
            end
            args.uniq!

            if args.length > 1
              msg = "Field '#{node.name}' has an argument conflict: #{args.map{ |arg| GraphQL8::Language.serialize(arg) }.join(" or ")}?"
              context.errors << GraphQL8::StaticValidation::Message.new(msg, nodes: node.ast_nodes.to_a)
            end
          end
        end
      end
    end
  end
end

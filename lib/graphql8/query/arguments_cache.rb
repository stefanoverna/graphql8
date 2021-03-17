# frozen_string_literal: true
# test_via: ../query.rb
module GraphQL8
  class Query
    module ArgumentsCache
      # @return [Hash<InternalRepresentation::Node, GraphQL8::Language::NodesDirectiveNode => Hash<GraphQL8::Field, GraphQL8::Directive => GraphQL8::Query::Arguments>>]
      def self.build(query)
        Hash.new do |h1, irep_or_ast_node|
          h1[irep_or_ast_node] = Hash.new do |h2, definition|
            ast_node = irep_or_ast_node.is_a?(GraphQL8::InternalRepresentation::Node) ? irep_or_ast_node.ast_node : irep_or_ast_node
            h2[definition] = if definition.arguments.none?
              GraphQL8::Query::Arguments::NO_ARGS
            else
              GraphQL8::Query::LiteralInput.from_arguments(
                ast_node.arguments,
                definition,
                query.variables,
              )
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true
module GraphQL8
  module Language
    # Exposes {.generate}, which turns AST nodes back into query strings.
    module Generation
      extend self

      # Turn an AST node back into a string.
      #
      # @example Turning a document into a query
      #    document = GraphQL8.parse(query_string)
      #    GraphQL8::Language::Generation.generate(document)
      #    # => "{ ... }"
      #
      # @param node [GraphQL8::Language::Nodes::AbstractNode] an AST node to recursively stringify
      # @param indent [String] Whitespace to add to each printed node
      # @param printer [GraphQL8::Language::Printer] An optional custom printer for printing AST nodes. Defaults to GraphQL8::Language::Printer
      # @return [String] Valid GraphQL8 for `node`
      def generate(node, indent: "", printer: GraphQL8::Language::Printer.new)
        printer.print(node, indent: indent)
      end
    end
  end
end

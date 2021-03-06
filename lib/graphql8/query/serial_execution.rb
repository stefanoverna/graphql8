# frozen_string_literal: true
require "graphql8/query/serial_execution/value_resolution"
require "graphql8/query/serial_execution/field_resolution"
require "graphql8/query/serial_execution/operation_resolution"
require "graphql8/query/serial_execution/selection_resolution"

module GraphQL8
  class Query
    class SerialExecution
      # This is the only required method for an Execution strategy.
      # You could create a custom execution strategy and configure your schema to
      # use that custom strategy instead.
      #
      # @param ast_operation [GraphQL8::Language::Nodes::OperationDefinition] The operation definition to run
      # @param root_type [GraphQL8::ObjectType] either the query type or the mutation type
      # @param query_object [GraphQL8::Query] the query object for this execution
      # @return [Hash] a spec-compliant GraphQL8 result, as a hash
      def execute(ast_operation, root_type, query_object)
        operation_resolution.resolve(
          query_object.irep_selection,
          root_type,
          query_object
        )
      end

      def field_resolution
        self.class::FieldResolution
      end

      def operation_resolution
        self.class::OperationResolution
      end

      def selection_resolution
        self.class::SelectionResolution
      end
    end
  end
end

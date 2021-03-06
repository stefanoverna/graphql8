# frozen_string_literal: true

module GraphQL8
  module Tracing
    class NewRelicTracing < PlatformTracing
      self.platform_keys = {
        "lex" => "GraphQL8/lex",
        "parse" => "GraphQL8/parse",
        "validate" => "GraphQL8/validate",
        "analyze_query" => "GraphQL8/analyze",
        "analyze_multiplex" => "GraphQL8/analyze",
        "execute_multiplex" => "GraphQL8/execute",
        "execute_query" => "GraphQL8/execute",
        "execute_query_lazy" => "GraphQL8/execute",
      }

      # @param set_transaction_name [Boolean] If true, the GraphQL8 operation name will be used as the transaction name.
      #   This is not advised if you run more than one query per HTTP request, for example, with `graphql-client` or multiplexing.
      #   It can also be specified per-query with `context[:set_new_relic_transaction_name]`.
      def initialize(options = {})
        @set_transaction_name = options.fetch(:set_transaction_name, false)
        super
      end

      def platform_trace(platform_key, key, data)
        if key == "execute_query"
          set_this_txn_name =  data[:query].context[:set_new_relic_transaction_name]
          if set_this_txn_name == true || (set_this_txn_name.nil? && @set_transaction_name)
            query = data[:query]
            # Set the transaction name based on the operation type and name
            selected_op = query.selected_operation
            if selected_op
              op_type = selected_op.operation_type
              op_name = selected_op.name || "anonymous"
            else
              op_type = "query"
              op_name = "anonymous"
            end

            NewRelic::Agent.set_transaction_name("GraphQL8/#{op_type}.#{op_name}")
          end
        end

        NewRelic::Agent::MethodTracerHelpers.trace_execution_scoped(platform_key) do
          yield
        end
      end

      def platform_field_key(type, field)
        "GraphQL8/#{type.name}/#{field.name}"
      end
    end
  end
end

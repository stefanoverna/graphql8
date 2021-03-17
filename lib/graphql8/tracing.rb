# frozen_string_literal: true
require "graphql8/tracing/active_support_notifications_tracing"
require "graphql8/tracing/platform_tracing"
require "graphql8/tracing/appsignal_tracing"
require "graphql8/tracing/data_dog_tracing"
require "graphql8/tracing/new_relic_tracing"
require "graphql8/tracing/scout_tracing"
require "graphql8/tracing/skylight_tracing"
require "graphql8/tracing/prometheus_tracing"

if defined?(PrometheusExporter::Server)
  require "graphql8/tracing/prometheus_tracing/graphql_collector"
end

module GraphQL8
  # Library entry point for performance metric reporting.
  #
  # __Warning:__ Installing/uninstalling tracers is not thread-safe. Do it during application boot only.
  #
  # @example Sending custom events
  #   GraphQL8::Tracing.trace("my_custom_event", { ... }) do
  #     # do stuff ...
  #   end
  #
  # @example Adding a tracer to a schema
  #  MySchema = GraphQL8::Schema.define do
  #    tracer MyTracer # <= responds to .trace(key, data, &block)
  #  end
  #
  # @example Adding a tracer to a query
  #   MySchema.execute(query_str, context: { backtrace: true })
  #
  # Events:
  #
  # Key | Metadata
  # ----|---------
  # lex | `{ query_string: String }`
  # parse | `{ query_string: String }`
  # validate | `{ query: GraphQL8::Query, validate: Boolean }`
  # analyze_multiplex |  `{ multiplex: GraphQL8::Execution::Multiplex }`
  # analyze_query | `{ query: GraphQL8::Query }`
  # execute_multiplex | `{ multiplex: GraphQL8::Execution::Multiplex }`
  # execute_query | `{ query: GraphQL8::Query }`
  # execute_query_lazy | `{ query: GraphQL8::Query?, multiplex: GraphQL8::Execution::Multiplex? }`
  # execute_field | `{ context: GraphQL8::Query::Context::FieldResolutionContext }`
  # execute_field_lazy | `{ context: GraphQL8::Query::Context::FieldResolutionContext }`
  #
  module Tracing
    # Objects may include traceable to gain a `.trace(...)` method.
    # The object must have a `@tracers` ivar of type `Array<<#trace(k, d, &b)>>`.
    # @api private
    module Traceable
      # @param key [String] The name of the event in GraphQL8 internals
      # @param metadata [Hash] Event-related metadata (can be anything)
      # @return [Object] Must return the value of the block
      def trace(key, metadata)
        call_tracers(0, key, metadata) { yield }
      end

      private

      # If there's a tracer at `idx`, call it and then increment `idx`.
      # Otherwise, yield.
      #
      # @param idx [Integer] Which tracer to call
      # @param key [String] The current event name
      # @param metadata [Object] The current event object
      # @return Whatever the block returns
      def call_tracers(idx, key, metadata)
        if idx == @tracers.length
          yield
        else
          @tracers[idx].trace(key, metadata) { call_tracers(idx + 1, key, metadata) { yield } }
        end
      end
    end

    class << self
      # Install a tracer to receive events.
      # @param tracer [<#trace(key, metadata)>]
      # @return [void]
      # @deprecated See {Schema#tracer} or use `context: { tracers: [...] }`
      def install(tracer)
        warn("GraphQL8::Tracing.install is deprecated, add it to the schema with `tracer(my_tracer)` instead.")
        if !tracers.include?(tracer)
          @tracers << tracer
        end
      end

      # @deprecated See {Schema#tracer} or use `context: { tracers: [...] }`
      def uninstall(tracer)
        @tracers.delete(tracer)
      end

      # @deprecated See {Schema#tracer} or use `context: { tracers: [...] }`
      def tracers
        @tracers ||= []
      end
    end
    # Initialize the array
    tracers

    module NullTracer
      module_function
      def trace(k, v)
        yield
      end
    end
  end
end

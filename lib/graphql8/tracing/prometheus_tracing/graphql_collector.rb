# frozen_string_literal: true

module GraphQL8
  module Tracing
    class PrometheusTracing < PlatformTracing
      class GraphQL8Collector < ::PrometheusExporter::Server::TypeCollector
        def initialize
          @graphql_gauge = PrometheusExporter::Metric::Summary.new(
            'graphql_duration_seconds',
            'Time spent in GraphQL8 operations, in seconds'
          )
        end

        def type
          'graphql8'
        end

        def collect(object)
          labels = { key: object['key'], platform_key: object['platform_key'] }
          @graphql_gauge.observe object['duration'], labels
        end

        def metrics
          [@graphql_gauge]
        end
      end
    end
  end
end

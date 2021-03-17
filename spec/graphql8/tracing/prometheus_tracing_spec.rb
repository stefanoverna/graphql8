# frozen_string_literal: true

require "spec_helper"

describe GraphQL8::Tracing::PrometheusTracing do
  module PrometheusTracingTest
    class Query < GraphQL8::Schema::Object
      field :int, Integer, null: false

      def int
        1
      end
    end

    class Schema < GraphQL8::Schema
      query Query
    end
  end

  describe "Observing" do
    it "sends JSON to Prometheus client" do
      client = Minitest::Mock.new

      client.expect :send_json, true do |obj|
        obj[:type] == 'graphql8' &&
          obj[:key] == 'execute_field' &&
          obj[:platform_key] == 'Query.int'
      end

      PrometheusTracingTest::Schema.use(
        GraphQL8::Tracing::PrometheusTracing,
        client: client,
        trace_scalars: true
      )

      PrometheusTracingTest::Schema.execute "query X { int }"
    end
  end
end

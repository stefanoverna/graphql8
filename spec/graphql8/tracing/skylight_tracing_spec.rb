# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Tracing::SkylightTracing do
  module SkylightTest
    class Query < GraphQL8::Schema::Object
      field :int, Integer, null: false

      def int
        1
      end
    end

    class SchemaWithoutTransactionName < GraphQL8::Schema
      query(Query)
      use(GraphQL8::Tracing::SkylightTracing)
    end

    class SchemaWithTransactionName < GraphQL8::Schema
      query(Query)
      use(GraphQL8::Tracing::SkylightTracing, set_endpoint_name: true)
    end

    class SchemaWithScalarTrace < GraphQL8::Schema
      query(Query)
      use(GraphQL8::Tracing::SkylightTracing, trace_scalars: true)
    end
  end

  before do
    Skylight.clear_all
  end

  it "can leave the transaction name in place" do
    SkylightTest::SchemaWithoutTransactionName.execute "query X { int }"
    assert_equal [], Skylight::ENDPOINT_NAMES
  end

  it "can override the transaction name" do
    SkylightTest::SchemaWithTransactionName.execute "query X { int }"
    assert_equal ["GraphQL8/query.X"], Skylight::ENDPOINT_NAMES
  end

  it "can override the transaction name per query" do
    # Override with `false`
    SkylightTest::SchemaWithTransactionName.execute "{ int }", context: { set_skylight_endpoint_name: false }
    assert_equal [], Skylight::ENDPOINT_NAMES
    # Override with `true`
    SkylightTest::SchemaWithoutTransactionName.execute "{ int }", context: { set_skylight_endpoint_name: true }
    assert_equal ["GraphQL8/query.<anonymous>"], Skylight::ENDPOINT_NAMES
  end

  it "traces scalars when trace_scalars is true" do
    SkylightTest::SchemaWithScalarTrace.execute "query X { int }"
    assert_includes Skylight::TITLE_NAMES, "graphql.Query.int"
  end
end

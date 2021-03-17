# frozen_string_literal: true
require "spec_helper"

describe "GraphQL8::Introspection::INTROSPECTION_QUERY" do
  let(:query_string) { GraphQL8::Introspection::INTROSPECTION_QUERY }
  let(:result) { Dummy::Schema.execute(query_string) }

  it "runs" do
    assert(result["data"])
  end

  it "handles deeply nested (<= 7) schemas" do
    query_type =  GraphQL8::ObjectType.define do
      name "DeepQuery"
       field :foo do
         type !GraphQL8::ListType.new(
           of_type: !GraphQL8::ListType.new(
             of_type: !GraphQL8::ListType.new(
               of_type: GraphQL8::FLOAT_TYPE
             )
           )
         )
       end
    end

     deep_schema = GraphQL8::Schema.define do
       query query_type
     end

     result = deep_schema.execute(query_string)
     assert(GraphQL8::Schema::Loader.load(result))
  end

  it "doesn't handle too deeply nested (< 8) schemas" do
    query_type =  GraphQL8::ObjectType.define do
      name "DeepQuery"
       field :foo do
         type !GraphQL8::ListType.new(
           of_type: !GraphQL8::ListType.new(
             of_type: !GraphQL8::ListType.new(
               of_type: !GraphQL8::ListType.new(
                 of_type: GraphQL8::FLOAT_TYPE
               )
             )
           )
         )
       end
    end

     deep_schema = GraphQL8::Schema.define do
       query query_type
     end

     result = deep_schema.execute(query_string)
     assert_raises(KeyError) {
       GraphQL8::Schema::Loader.load(result)
     }
  end
end

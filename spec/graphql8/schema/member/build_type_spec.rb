# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Schema::Member::BuildType do
  describe ".parse_type" do
    it "resolves a string type from a string" do
      assert_equal GraphQL8::Types::String, GraphQL8::Schema::Member::BuildType.parse_type("String", null: true)
    end

    it "resolves an integer type from a string" do
      assert_equal GraphQL8::Types::Int, GraphQL8::Schema::Member::BuildType.parse_type("Integer", null: true)
    end

    it "resolves a float type from a string" do
      assert_equal GraphQL8::Types::Float, GraphQL8::Schema::Member::BuildType.parse_type("Float", null: true)
    end

    it "resolves a boolean type from a string" do
      assert_equal GraphQL8::Types::Boolean, GraphQL8::Schema::Member::BuildType.parse_type("Boolean", null: true)
    end

    it "resolves an interface type from a string" do
      assert_equal Jazz::BaseInterface, GraphQL8::Schema::Member::BuildType.parse_type("Jazz::BaseInterface", null: true)
    end

    it "resolves an object type from a class" do
      assert_equal Jazz::BaseObject, GraphQL8::Schema::Member::BuildType.parse_type(Jazz::BaseObject, null: true)
    end

    it "resolves an object type from a string" do
      assert_equal Jazz::BaseObject, GraphQL8::Schema::Member::BuildType.parse_type("Jazz::BaseObject", null: true)
    end

    it "resolves a nested object type from a string" do
      assert_equal Jazz::Introspection::NestedType, GraphQL8::Schema::Member::BuildType.parse_type("Jazz::Introspection::NestedType", null: true)
    end

    it "resolves a deeply nested object type from a string" do
      assert_equal Jazz::Introspection::NestedType::DeeplyNestedType, GraphQL8::Schema::Member::BuildType.parse_type("Jazz::Introspection::NestedType::DeeplyNestedType", null: true)
    end

    it "resolves a list type from an array of classes" do
      assert_instance_of GraphQL8::Schema::List, GraphQL8::Schema::Member::BuildType.parse_type([Jazz::BaseObject], null: true)
    end

    it "resolves a list type from an array of strings" do
      assert_instance_of GraphQL8::Schema::List, GraphQL8::Schema::Member::BuildType.parse_type(["Jazz::BaseObject"], null: true)
    end
  end

  describe ".to_type_name" do
    it "works with lists and non-nulls" do
      t = Class.new(GraphQL8::Schema::Object) do
        graphql_name "T"
      end

      req_t = GraphQL8::Schema::NonNull.new(t)
      list_req_t = GraphQL8::Schema::List.new(req_t)

      assert_equal "T", GraphQL8::Schema::Member::BuildType.to_type_name(list_req_t)
    end
  end
end

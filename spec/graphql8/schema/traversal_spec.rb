# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Schema::Traversal do
  def traversal(types)
    schema = GraphQL8::Schema.define(orphan_types: types, resolve_type: :dummy)
    GraphQL8::Schema::Traversal.new(schema, introspection: false)
  end

  it "finds types from directives" do
    expected = {
      "Boolean" => GraphQL8::BOOLEAN_TYPE, # `skip` argument
      "String" => GraphQL8::STRING_TYPE # `deprecated` argument
    }
    result = traversal([]).type_map
    assert_equal(expected.keys.sort, result.keys.sort)
    assert_equal(expected, result.to_h)
  end

  it "finds types from a single type and its fields" do
    expected = {
      "Boolean" => GraphQL8::BOOLEAN_TYPE,
      "Cheese" => Dummy::Cheese.graphql_definition,
      "Float" => GraphQL8::FLOAT_TYPE,
      "String" => GraphQL8::STRING_TYPE,
      "Edible" => Dummy::Edible.graphql_definition,
      "EdibleAsMilk" => Dummy::EdibleAsMilk.graphql_definition,
      "DairyAnimal" => Dummy::DairyAnimal.graphql_definition,
      "Int" => GraphQL8::INT_TYPE,
      "AnimalProduct" => Dummy::AnimalProduct.graphql_definition,
      "LocalProduct" => Dummy::LocalProduct.graphql_definition,
    }
    result = traversal([Dummy::Cheese.graphql_definition]).type_map
    assert_equal(expected.keys.sort, result.keys.sort)
    assert_equal(expected, result.to_h)
  end

  it "finds type from arguments" do
    result = traversal([Dummy::DairyAppQuery.graphql_definition]).type_map
    assert_equal(Dummy::DairyProductInput.graphql_definition, result["DairyProductInput"])
  end

  it "finds types from field instrumentation" do
    type = GraphQL8::ObjectType.define do
      name "ArgTypeTest"
      connection :t, type.connection_type
    end

    result = traversal([type]).type_map
    expected_types = [
      "ArgTypeTest", "ArgTypeTestConnection", "ArgTypeTestEdge",
      "Boolean", "Int", "PageInfo", "String"
    ]
    assert_equal expected_types, result.keys.sort
  end

  it "finds types from nested InputObjectTypes" do
    type_child = GraphQL8::InputObjectType.define do
      name "InputTypeChild"
      input_field :someField, GraphQL8::STRING_TYPE
    end

    type_parent = GraphQL8::InputObjectType.define do
      name "InputTypeParent"
      input_field :child, type_child
    end

    result = traversal([type_parent]).type_map
    expected = {
      "Boolean" => GraphQL8::BOOLEAN_TYPE,
      "String" => GraphQL8::STRING_TYPE,
      "InputTypeParent" => type_parent,
      "InputTypeChild" => type_child,
    }
    assert_equal(expected, result.to_h)
  end

  describe "when a type is invalid" do
    let(:invalid_type) {
      GraphQL8::ObjectType.define do
        name "InvalidType"
        field :someField
      end
    }

    let(:another_invalid_type) {
      GraphQL8::ObjectType.define do
        name "AnotherInvalidType"
        field :someField, String
      end
    }

    it "raises an InvalidTypeError when passed nil" do
      assert_raises(GraphQL8::Schema::InvalidTypeError) {  traversal([invalid_type]) }
    end

    it "raises an InvalidTypeError when passed an object that isnt a GraphQL8::BaseType" do
      assert_raises(GraphQL8::Schema::InvalidTypeError) {  traversal([another_invalid_type]) }
    end
  end

  describe "when a schema has multiple types with the same name" do
    let(:type_1) {
      GraphQL8::ObjectType.define do
        name "MyType"
      end
    }
    let(:type_2) {
      GraphQL8::ObjectType.define do
        name "MyType"
      end
    }
    it "raises an error" do
      assert_raises(RuntimeError) {
        traversal([type_1, type_2])
      }
    end
  end

  describe "when getting a type which doesnt exist" do
    it "raises an error" do
      type_map = traversal([]).type_map
      assert_raises(KeyError) { type_map.fetch("SomeType") }
    end
  end

  describe "when a field is only accessible through an interface" do
    it "is found through Schema.define(types:)" do
      assert_equal Dummy::Honey.graphql_definition, Dummy::Schema.types["Honey"]
    end
  end

  it "finds all references to types from fields and arguments" do
    c_type = GraphQL8::InputObjectType.define do
      name "C"
      input_field :someField, GraphQL8::STRING_TYPE
    end

    b_type = GraphQL8::ObjectType.define do
      name "B"
      field :anotherField, !GraphQL8::STRING_TYPE do |field|
        field.argument :anArgument, c_type
      end
    end

    a_type = GraphQL8::ObjectType.define do
      name "A"
      field :someField, b_type
    end

    include_if_argument = GraphQL8::Directive::IncludeDirective.arguments["if"]
    skip_if_argument = GraphQL8::Directive::SkipDirective.arguments["if"]
    deprecated_reason_argument = GraphQL8::Directive::DeprecatedDirective.arguments["reason"]

    expected = {
      "Boolean" => [include_if_argument, skip_if_argument],
      "B" => [a_type.fields["someField"]],
      "String" => [deprecated_reason_argument, b_type.fields["anotherField"], c_type.input_fields["someField"]],
      "C" => [b_type.fields["anotherField"].arguments["anArgument"]]
    }

    assert_equal expected, traversal([a_type, b_type, c_type]).type_reference_map
  end

  it "finds unions from which types are members" do
    b_type = GraphQL8::ObjectType.define do
      name "B"
    end

    c_type = GraphQL8::ObjectType.define do
      name "C"
    end

    union = GraphQL8::UnionType.define do
      name "AUnion"
      possible_types [b_type]
    end

    another_union = GraphQL8::UnionType.define do
      name "AnotherUnion"
      possible_types [b_type, c_type]
    end

    result = traversal([union, another_union, b_type, c_type]).union_memberships
    expected = {
      "B" => [union, another_union],
      "C" => [another_union]
    }
    assert_equal expected, result
  end

  it "finds orphan types from interfaces" do
    b_type = GraphQL8::ObjectType.define do
      name "B"
    end

    c_type = GraphQL8::ObjectType.define do
      name "C"
    end

    interface = GraphQL8::InterfaceType.define do
      name "AInterface"
      orphan_types [b_type]
    end

    another_interface = GraphQL8::InterfaceType.define do
      name "AnotherIterface"
      orphan_types [b_type, c_type]
    end

    result = traversal([interface, another_interface]).type_map
    expected = {
      "Boolean" => GraphQL8::BOOLEAN_TYPE,
      "String" => GraphQL8::STRING_TYPE,
      "AInterface" => interface,
      "AnotherIterface" => another_interface,
      "B" => b_type,
      "C" => c_type
    }
    assert_equal expected, result
  end
end

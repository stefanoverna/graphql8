# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Schema::Member::TypeSystemHelpers do
  let(:object) {
    Class.new(GraphQL8::Schema::Object) do
      graphql_name "Thing"

      field :int, Integer, null: true
      field :int2, Integer, null: false
      field :int_list, [Integer], null: true
      field :int_list2, [Integer], null: false
    end
  }

  let(:int_field) { object.fields["int"] }
  let(:int2_field) { object.fields["int2"] }
  let(:int_list_field) { object.fields["intList"] }
  let(:int_list2_field) { object.fields["intList2"] }

  describe "#list?" do
    it "is true for lists, including non-null lists, otherwise false" do
      assert int_list_field.type.list?
      assert int_list2_field.type.list?
      refute int_field.type.list?
      refute int2_field.type.list?
    end
  end

  describe "#non_null?" do
    it "is true for required types" do
      assert int2_field.type.non_null?
      assert int_list2_field.type.non_null?
      refute int_field.type.non_null?
      refute int_list_field.type.non_null?
    end
  end

  describe "#kind" do
    let(:pairs) {{
      GraphQL8::Schema::Object => "OBJECT",
      GraphQL8::Schema::Union => "UNION",
      GraphQL8::Schema::Interface => "INTERFACE",
      GraphQL8::Schema::Enum => "ENUM",
      GraphQL8::Schema::InputObject => "INPUT_OBJECT",
      GraphQL8::Schema::Scalar => "SCALAR",
    }}
    it "returns the TypeKind instance" do
      pairs.each do |type_class, type_kind_name|
        type = if type_class.is_a?(Class)
          Class.new(type_class)
        else
          Module.new { include(type_class) }
        end

        assert_equal type_kind_name, type.kind.name
      end

      assert_equal "LIST", GraphQL8::Schema::Object.to_list_type.kind.name
      assert_equal "NON_NULL", GraphQL8::Schema::Object.to_non_null_type.kind.name
    end
  end
end

# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Language::Visitor do
  let(:document) { GraphQL8.parse("
    query cheese {
      cheese(id: 1) {
        flavor,
        source,
        producers(first: 3) {
          name
        }
        ... cheeseFields
      }
    }

    fragment cheeseFields on Cheese { flavor }
    ")}
  let(:counts) { {fields_entered: 0, arguments_entered: 0, arguments_left: 0, argument_names: []} }

  let(:visitor) do
    v = GraphQL8::Language::Visitor.new(document)
    v[GraphQL8::Language::Nodes::Field] << ->(node, parent) { counts[:fields_entered] += 1 }
    # two ways to set up enter hooks:
    v[GraphQL8::Language::Nodes::Argument] <<       ->(node, parent) { counts[:argument_names] << node.name }
    v[GraphQL8::Language::Nodes::Argument].enter << ->(node, parent) { counts[:arguments_entered] += 1}
    v[GraphQL8::Language::Nodes::Argument].leave << ->(node, parent) { counts[:arguments_left] += 1 }

    v[GraphQL8::Language::Nodes::Document].leave << ->(node, parent) { counts[:finished] = true }
    v
  end

  it "calls hooks during a depth-first tree traversal" do
    assert_equal(2, visitor[GraphQL8::Language::Nodes::Argument].enter.length)
    visitor.visit
    assert_equal(6, counts[:fields_entered])
    assert_equal(2, counts[:arguments_entered])
    assert_equal(2, counts[:arguments_left])
    assert_equal(["id", "first"], counts[:argument_names])
    assert(counts[:finished])
  end

  it "can visit a document with directive definitions" do
    document = GraphQL8.parse("
      # Marks an element of a GraphQL8 schema as only available via a preview header
      directive @preview(
        # The identifier of the API preview that toggles this field.
        toggledBy: String
      ) on SCALAR | OBJECT | FIELD_DEFINITION | ARGUMENT_DEFINITION | INTERFACE | UNION | ENUM | ENUM_VALUE | INPUT_OBJECT | INPUT_FIELD_DEFINITION

      type Query {
        hello: String
      }
    ")

    directive = nil
    directive_locations = []

    v = GraphQL8::Language::Visitor.new(document)
    v[GraphQL8::Language::Nodes::DirectiveDefinition] << ->(node, parent) { directive = node }
    v[GraphQL8::Language::Nodes::DirectiveLocation] << ->(node, parent) { directive_locations << node }
    v.visit

    assert_equal "preview", directive.name
    assert_equal 10, directive_locations.length
  end

  describe "Visitor::SKIP" do
    it "skips the rest of the node" do
      visitor[GraphQL8::Language::Nodes::Document] << ->(node, parent) { GraphQL8::Language::Visitor::SKIP }
      visitor.visit
      assert_equal(0, counts[:fields_entered])
    end
  end

  it "can visit InputObjectTypeDefinition directives" do
    schema_sdl = <<-GRAPHQL
    input Test @directive {
      id: ID!
    }
    GRAPHQL

    document = GraphQL8.parse(schema_sdl)

    visitor = GraphQL8::Language::Visitor.new(document)

    visited_directive = false
    visitor[GraphQL8::Language::Nodes::Directive] << ->(node, parent) { visited_directive = true }

    visitor.visit

    assert visited_directive
  end
end

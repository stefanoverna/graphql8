# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Language::Nodes::AbstractNode do
  describe "#filename" do
    it "is set after .parse_file" do
      filename = "spec/support/parser/filename_example.graphql"
      doc = GraphQL8.parse_file(filename)
      op = doc.definitions.first
      field = op.selections.first
      arg = field.arguments.first

      assert_equal filename, doc.filename
      assert_equal filename, op.filename
      assert_equal filename, field.filename
      assert_equal filename, arg.filename
    end

    it "is null when parse from string" do
      doc = GraphQL8.parse("{ thing }")
      assert_nil doc.filename
    end
  end

  describe "#to_query_tring" do
    let(:document) {
      GraphQL8.parse('type Query { a: String! }')
    }

    let(:custom_printer_class) {
      Class.new(GraphQL8::Language::Printer) {
        def print_field_definition(print_field_definition)
          "<Field Hidden>"
        end
      }
    }

    it "accepts a custom printer" do
      expected = <<-SCHEMA
type Query {
  <Field Hidden>
}
      SCHEMA
      assert_equal expected.chomp, document.to_query_string(printer: custom_printer_class.new)
    end
  end
end

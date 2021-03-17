# frozen_string_literal: true
require "spec_helper"

BuiltInSchemaParserSuite = GraphQL8::Compatibility::SchemaParserSpecification.build_suite do |query_string|
  GraphQL8::Language::Parser.parse(query_string)
end

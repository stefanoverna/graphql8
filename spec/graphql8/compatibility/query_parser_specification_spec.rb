# frozen_string_literal: true
require "spec_helper"

BuiltInQueryParserSuite = GraphQL8::Compatibility::QueryParserSpecification.build_suite do |query_string|
  GraphQL8::Language::Parser.parse(query_string)
end

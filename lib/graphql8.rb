# frozen_string_literal: true
require "delegate"
require "json"
require "set"
require "singleton"
require "forwardable"
require_relative "./graphql8/railtie" if defined? Rails::Railtie

module GraphQL8
  class Error < StandardError
  end

  # Turn a query string or schema definition into an AST
  # @param graphql_string [String] a GraphQL8 query string or schema definition
  # @return [GraphQL8::Language::Nodes::Document]
  def self.parse(graphql_string, tracer: GraphQL8::Tracing::NullTracer)
    parse_with_racc(graphql_string, tracer: tracer)
  end

  # Read the contents of `filename` and parse them as GraphQL8
  # @param filename [String] Path to a `.graphql` file containing IDL or query
  # @return [GraphQL8::Language::Nodes::Document]
  def self.parse_file(filename)
    content = File.read(filename)
    parse_with_racc(content, filename: filename)
  end

  def self.parse_with_racc(string, filename: nil, tracer: GraphQL8::Tracing::NullTracer)
    GraphQL8::Language::Parser.parse(string, filename: filename, tracer: tracer)
  end

  # @return [Array<GraphQL8::Language::Token>]
  def self.scan(graphql_string)
    scan_with_ragel(graphql_string)
  end

  def self.scan_with_ragel(graphql_string)
    GraphQL8::Language::Lexer.tokenize(graphql_string)
  end
end

# Order matters for these:

require "graphql8/execution_error"
require "graphql8/define"
require "graphql8/base_type"
require "graphql8/object_type"

require "graphql8/enum_type"
require "graphql8/input_object_type"
require "graphql8/interface_type"
require "graphql8/list_type"
require "graphql8/non_null_type"
require "graphql8/union_type"

require "graphql8/argument"
require "graphql8/field"
require "graphql8/type_kinds"

require "graphql8/backwards_compatibility"
require "graphql8/scalar_type"

require "graphql8/directive"
require "graphql8/name_validator"

require "graphql8/language"
require "graphql8/analysis"
require "graphql8/tracing"
require "graphql8/execution"
require "graphql8/dig"
require "graphql8/schema"
require "graphql8/types"
require "graphql8/relay"
require "graphql8/boolean_type"
require "graphql8/float_type"
require "graphql8/id_type"
require "graphql8/int_type"
require "graphql8/string_type"
require "graphql8/schema/built_in_types"
require "graphql8/schema/loader"
require "graphql8/schema/printer"
require "graphql8/introspection"

require "graphql8/analysis_error"
require "graphql8/coercion_error"
require "graphql8/literal_validation_error"
require "graphql8/runtime_type_error"
require "graphql8/invalid_null_error"
require "graphql8/invalid_name_error"
require "graphql8/unresolved_type_error"
require "graphql8/string_encoding_error"
require "graphql8/query"
require "graphql8/internal_representation"
require "graphql8/static_validation"
require "graphql8/version"
require "graphql8/compatibility"
require "graphql8/function"
require "graphql8/filter"
require "graphql8/subscriptions"
require "graphql8/parse_error"
require "graphql8/backtrace"

require "graphql8/deprecated_dsl"
require "graphql8/authorization"
require "graphql8/unauthorized_error"

# frozen_string_literal: true
require "graphql8/language/block_string"
require "graphql8/language/printer"
require "graphql8/language/definition_slice"
require "graphql8/language/document_from_schema_definition"
require "graphql8/language/generation"
require "graphql8/language/lexer"
require "graphql8/language/nodes"
require "graphql8/language/parser"
require "graphql8/language/token"
require "graphql8/language/visitor"

module GraphQL8
  module Language
    # @api private
    def self.serialize(value)
      if value.is_a?(Hash)
        serialized_hash = value.map do |k, v|
          "#{k}:#{serialize v}"
        end.join(",")

        "{#{serialized_hash}}"
      elsif value.is_a?(Array)
        serialized_array = value.map do |v|
          serialize v
        end.join(",")

        "[#{serialized_array}]"
      else
        JSON.generate(value, quirks_mode: true)
      end
    end
  end
end

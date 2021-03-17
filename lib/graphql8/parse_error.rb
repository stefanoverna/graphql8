# frozen_string_literal: true
# test_via: language/parser.rb
module GraphQL8
  class ParseError < GraphQL8::Error
    attr_reader :line, :col, :query
    def initialize(message, line, col, query, filename: nil)
      if filename
        message += " (#{filename})"
      end

      super(message)
      @line = line
      @col = col
      @query = query
    end

    def to_h
      locations = line ? [{ "line" => line, "column" => col }] : []
      {
        "message" => message,
        "locations" => locations,
      }
    end
  end
end

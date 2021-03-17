# frozen_string_literal: true
module GraphQL8
  class LiteralValidationError < GraphQL8::Error
    attr_accessor :ast_value
  end
end

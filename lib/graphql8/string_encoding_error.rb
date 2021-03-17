# frozen_string_literal: true
module GraphQL8
  class StringEncodingError < GraphQL8::RuntimeTypeError
    attr_reader :string
    def initialize(str)
      @string = str
      super("String \"#{str}\" was encoded as #{str.encoding}! GraphQL8 requires an encoding compatible with UTF-8.")
    end
  end
end

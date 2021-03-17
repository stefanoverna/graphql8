# frozen_string_literal: true
module GraphQL8
  class InvalidNameError < GraphQL8::ExecutionError
    attr_reader :name, :valid_regex
    def initialize(name, valid_regex)
      @name = name
      @valid_regex = valid_regex
      super("Names must match #{@valid_regex.inspect} but '#{@name}' does not")
    end
  end
end

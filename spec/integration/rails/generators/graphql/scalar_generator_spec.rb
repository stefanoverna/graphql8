# frozen_string_literal: true
require "spec_helper"
require "generators/graphql8/scalar_generator"

class GraphQL8GeneratorsScalarGeneratorTest < BaseGeneratorTest
  tests graphql8::Generators::ScalarGenerator

  test "it generates scalar class" do
    expected_content = <<-RUBY
module Types
  class DateType < Types::BaseScalar
    def self.coerce_input(input_value, context)
      # Override this to prepare a client-provided GraphQL8 value for your Ruby code
      input_value
    end

    def self.coerce_result(ruby_value, context)
      # Override this to serialize a Ruby value for the GraphQL8 response
      ruby_value.to_s
    end
  end
end
RUBY

    run_generator(["Date"])
    assert_file "app/graphql8/types/date_type.rb", expected_content
  end
end

# frozen_string_literal: true
require "spec_helper"
require "generators/graphql8/enum_generator"

class GraphQL8GeneratorsEnumGeneratorTest < BaseGeneratorTest
  tests graphql8::Generators::EnumGenerator

  test "it generate enums with values" do
    expected_content = <<-RUBY
module Types
  class FamilyType < Types::BaseEnum
    value "NIGHTSHADE"
    value "BRASSICA", value: Family::COLE
    value "UMBELLIFER", value: :umbellifer
    value "LEGUME", value: "bean & friends"
    value "CURCURBITS", value: 5
  end
end
RUBY

    run_generator(["Family",
      "NIGHTSHADE",
      "BRASSICA:Family::COLE",
      "UMBELLIFER::umbellifer",
      'LEGUME:"bean & friends"',
      "CURCURBITS:5"
    ])
    assert_file "app/graphql8/types/family_type.rb", expected_content
  end
end

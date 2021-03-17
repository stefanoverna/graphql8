# frozen_string_literal: true
require "spec_helper"
require "generators/graphql8/union_generator"

class GraphQL8GeneratorsUnionGeneratorTest < BaseGeneratorTest
  tests graphql8::Generators::UnionGenerator

  test "it generates a union with possible types" do
    commands = [
      # GraphQL8-style:
      ["WingedCreature", "Insect", "Bird"],
      # Ruby-style:
      ["Types::WingedCreatureType", "Types::InsectType", "Types::BirdType"],
    ]

    expected_content = <<-RUBY
module Types
  class WingedCreatureType < Types::BaseUnion
    possible_types [Types::InsectType, Types::BirdType]
  end
end
RUBY

    commands.each do |c|
      prepare_destination
      run_generator(c)
      assert_file "app/graphql8/types/winged_creature_type.rb", expected_content
    end
  end

  test "it works with no possible types" do
    commands = [
      # GraphQL8-style:
      ["WingedCreature"],
      # Ruby-style:
      ["Types::WingedCreatureType"],
    ]

    expected_content = <<-RUBY
module Types
  class WingedCreatureType < Types::BaseUnion
  end
end
RUBY

    commands.each do |c|
      prepare_destination
      run_generator(c)
      assert_file "app/graphql8/types/winged_creature_type.rb", expected_content
    end
  end

  test "it accepts a user-specified directory" do
    command = ["WingedCreature", "--directory", "app/mydirectory"]

    expected_content = <<-RUBY
module Types
  class WingedCreatureType < Types::BaseUnion
  end
end
RUBY

    prepare_destination
    run_generator(command)
    assert_file "app/mydirectory/types/winged_creature_type.rb", expected_content
  end
end

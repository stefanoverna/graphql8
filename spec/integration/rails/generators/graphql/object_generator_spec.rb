# frozen_string_literal: true
require "spec_helper"
require "generators/graphql8/object_generator"

class GraphQL8GeneratorsObjectGeneratorTest < BaseGeneratorTest
  tests graphql8::Generators::ObjectGenerator

  test "it generates fields with types" do
    commands = [
      # GraphQL8-style:
      ["Bird", "wingspan:Int!", "foliage:[Color]"],
      # Ruby-style:
      ["BirdType", "wingspan:!Integer", "foliage:[Types::ColorType]"],
      # Mixed
      ["BirdType", "wingspan:!Int", "foliage:[Color]"],
    ]

    expected_content = <<-RUBY
module Types
  class BirdType < Types::BaseObject
    field :wingspan, Integer, null: false
    field :foliage, [Types::ColorType], null: true
  end
end
RUBY

    commands.each do |c|
      prepare_destination
      run_generator(c)
      assert_file "app/graphql8/types/bird_type.rb", expected_content
    end
  end

  test "it generates classifed file" do
    run_generator(["page"])
    assert_file "app/graphql8/types/page_type.rb", <<-RUBY
module Types
  class PageType < Types::BaseObject
  end
end
RUBY
  end

  test "it makes Relay nodes" do
    run_generator(["Page", "--node"])
    assert_file "app/graphql8/types/page_type.rb", <<-RUBY
module Types
  class PageType < Types::BaseObject
    implements GraphQL8::Relay::Node.interface
  end
end
RUBY
  end
end

# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::StaticValidation::FragmentsAreFinite do
  include StaticValidationHelpers

  let(:query_string) {%|
    query getCheese {
      cheese(id: 1) {
        ... idField
        ... sourceField
        similarCheese(source: SHEEP) {
          ... flavorField
        }
      }
    }

    fragment sourceField on Cheese {
      source,
      ... flavorField
      ... idField
    }
    fragment flavorField on Cheese {
      flavor,
      similarCheese(source: SHEEP) {
        ... on Cheese {
          ... sourceField
        }
      }
    }
    fragment idField on Cheese {
      id
    }
  |}

  it "doesnt allow infinite loops" do
    expected = [
      {
        "message"=>"Fragment sourceField contains an infinite loop",
        "locations"=>[{"line"=>12, "column"=>5}],
        "fields"=>["fragment sourceField"],
      },
      {
        "message"=>"Fragment flavorField contains an infinite loop",
        "locations"=>[{"line"=>17, "column"=>5}],
        "fields"=>["fragment flavorField"],
      }
    ]
    assert_equal(expected, errors)
  end

  describe "undefined spreads inside fragments" do
    let(:query_string) {%|
      {
        cheese(id: 1) { ... frag1 }
      }
      fragment frag1 on Cheese { id, ...frag2 }
    |}

    it "doesn't blow up" do
      assert_equal("Fragment frag2 was used, but not defined", errors.first["message"])
    end
  end

  describe "a duplicate fragment name with a loop" do
    let(:query_string) {%|
      {
        cheese(id: 1) { ... frag1 }
      }
      fragment frag1 on Cheese { id }
      fragment frag1 on Cheese { ...frag1 }
    |}

    it "detects the loop" do
      assert_equal 2, errors.length
      assert_equal("Fragment frag1 contains an infinite loop", errors[0]["message"])
      assert_equal("Fragment name \"frag1\" must be unique", errors[1]["message"])
    end
  end

  describe "a duplicate operation name with a loop" do
    let(:query_string) {%|
      fragment frag1 on Cheese { ...frag1 }

      query frag1 {
        cheese(id: 1) {
          ... frag1
        }
      }
    |}

    it "detects the loop" do
      assert_equal 1, errors.length
      assert_equal("Fragment frag1 contains an infinite loop", errors[0]["message"])
    end
  end

  describe "several duplicate operation names with a loop" do
    let(:query_string) {%|
      query frag1 {
        cheese(id: 1) {
          id
        }
      }

      fragment frag1 on Cheese { ...frag1 }

      query frag1 {
        cheese(id: 1) {
          ... frag1
        }
      }
    |}

    it "detects the loop" do
      assert_equal 2, errors.length
      assert_equal("Fragment frag1 contains an infinite loop", errors[0]["message"])
      assert_equal("Operation name \"frag1\" must be unique", errors[1]["message"])
    end
  end
end

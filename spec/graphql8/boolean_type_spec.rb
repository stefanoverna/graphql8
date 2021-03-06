# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::BOOLEAN_TYPE do
  describe "coerce_input" do
    def coerce_input(input)
      GraphQL8::BOOLEAN_TYPE.coerce_isolated_input(input)
    end

    it "accepts true and false" do
      assert_equal true, coerce_input(true)
      assert_equal false, coerce_input(false)
    end

    it "rejects other types" do
      assert_nil coerce_input("true")
      assert_nil coerce_input(5.5)
      assert_nil coerce_input(nil)
    end
  end
end

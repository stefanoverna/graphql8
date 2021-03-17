# frozen_string_literal: true
require "spec_helper"

module InstrumentationSpec
  module SomeInterface
    include GraphQL8::Schema::Interface
    field :never_called, String, null: false

    def never_called
      "should never be called"
    end
  end

  class SomeType < GraphQL8::Schema::Object
    implements SomeInterface
  end

  class Query < GraphQL8::Schema::Object
    field :some_field, [SomeInterface], null: true

    def some_field
      nil
    end
  end

  class Schema < GraphQL8::Schema
    query Query
    orphan_types [SomeType]
  end
end

describe GraphQL8::Schema::Member::Instrumentation do
  describe "resolving nullable interface lists to nil" do
    let(:query) { "query { someField { neverCalled } }"}
    it "returns nil instead of failing" do
      result = InstrumentationSpec::Schema.execute(query)
      assert_nil(result["someField"])
    end
  end
end

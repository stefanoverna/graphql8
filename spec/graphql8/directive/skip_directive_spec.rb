# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Directive::SkipDirective do
  let(:directive) { GraphQL8::Directive::SkipDirective }
  it "is a default directive" do
    assert directive.default_directive?
  end
end

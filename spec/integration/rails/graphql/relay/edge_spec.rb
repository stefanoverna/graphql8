# frozen_string_literal: true
require "spec_helper"

describe GraphQL8::Relay::Edge do
  it "inspects nicely" do
    connection = OpenStruct.new(parent: "Parent")
    edge = GraphQL8::Relay::Edge.new("Node", connection)
    assert_equal '#<GraphQL8::Relay::Edge ("Parent" => "Node")>', edge.inspect
  end
end

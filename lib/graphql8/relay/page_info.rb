# frozen_string_literal: true
module GraphQL8
  module Relay
    # Wrap a Connection and expose its page info
    PageInfo = GraphQL8::Types::Relay::PageInfo.graphql_definition
  end
end

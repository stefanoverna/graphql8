# frozen_string_literal: true
require "graphql8/types/relay/base_field"
require "graphql8/types/relay/base_object"
require "graphql8/types/relay/base_interface"
require "graphql8/types/relay/page_info"
require "graphql8/types/relay/base_connection"
require "graphql8/types/relay/base_edge"
require "graphql8/types/relay/node"

module GraphQL8
  module Types
    # This module contains some types and fields that could support Relay conventions in GraphQL8.
    #
    # You can use these classes out of the box if you want, but if you want to use your _own_
    # GraphQL8 extensions along with the features in this code, you could also
    # open up the source files and copy the relevant methods and configuration into
    # your own classes.
    #
    # For example, the provided object types extend {Types::Relay::BaseObject},
    # but you might want to:
    #
    # 1. Migrate the extensions from {Types::Relay::BaseObject} into _your app's_ base object
    # 2. Copy {Relay::BaseConnection}, {Relay::BaseEdge}, etc into _your app_, and
    #   change them to extend _your_ base object.
    #
    # Similarly, `BaseField`'s extensions could be migrated to your app
    # and `Node` could be implemented to mix in your base interface module.
    module Relay
    end
  end
end

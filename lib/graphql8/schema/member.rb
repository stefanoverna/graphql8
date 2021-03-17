# frozen_string_literal: true
require 'graphql8/schema/member/accepts_definition'
require 'graphql8/schema/member/base_dsl_methods'
require 'graphql8/schema/member/cached_graphql_definition'
require 'graphql8/schema/member/graphql_type_names'
require 'graphql8/schema/member/has_path'
require 'graphql8/schema/member/relay_shortcuts'
require 'graphql8/schema/member/scoped'
require 'graphql8/schema/member/type_system_helpers'
require "graphql8/relay/type_extensions"

module GraphQL8
  class Schema
    # The base class for things that make up the schema,
    # eg objects, enums, scalars.
    #
    # @api private
    class Member
      include GraphQL8TypeNames
      extend CachedGraphQL8Definition
      extend GraphQL8::Relay::TypeExtensions
      extend BaseDSLMethods
      extend TypeSystemHelpers
      extend Scoped
      extend RelayShortcuts
      extend HasPath
    end
  end
end

require 'graphql8/schema/member/has_arguments'
require 'graphql8/schema/member/has_fields'
require 'graphql8/schema/member/instrumentation'
require 'graphql8/schema/member/build_type'

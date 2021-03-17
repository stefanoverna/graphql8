# frozen_string_literal: true
require "graphql8/define/assign_argument"
require "graphql8/define/assign_connection"
require "graphql8/define/assign_enum_value"
require "graphql8/define/assign_global_id_field"
require "graphql8/define/assign_mutation_function"
require "graphql8/define/assign_object_field"
require "graphql8/define/defined_object_proxy"
require "graphql8/define/instance_definable"
require "graphql8/define/no_definition_error"
require "graphql8/define/non_null_with_bang"
require "graphql8/define/type_definer"

module GraphQL8
  module Define
    # A helper for definitions that store their value in `#metadata`.
    #
    # @example Storing application classes with GraphQL8 types
    #   # Make a custom definition
    #   GraphQL8::ObjectType.accepts_definitions(resolves_to_class_names: GraphQL8::Define.assign_metadata_key(:resolves_to_class_names))
    #
    #   # After definition, read the key from metadata
    #   PostType.metadata[:resolves_to_class_names] # => [...]
    #
    # @param key [Object] the key to assign in metadata
    # @return [#call(defn, value)] an assignment for `.accepts_definitions` which writes `key` to `#metadata`
    def self.assign_metadata_key(key)
      GraphQL8::Define::InstanceDefinable::AssignMetadataKey.new(key)
    end
  end
end

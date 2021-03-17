# frozen_string_literal: true
require 'generators/graphql8/type_generator'

module Graphql
  module Generators
    # Generate an object type by name,
    # with the specified fields.
    #
    # ```
    # rails g graphql8:object PostType name:String!
    # ```
    #
    # Add the Node interface with `--node`.
    class ObjectGenerator < TypeGeneratorBase
      desc "Create a GraphQL8::ObjectType with the given name and fields"
      source_root File.expand_path('../templates', __FILE__)

      argument :fields,
        type: :array,
        default: [],
        banner: "name:type name:type ...",
        desc: "Fields for this object (type may be expressed as Ruby or GraphQL8)"

      class_option :node,
        type: :boolean,
        default: false,
        desc: "Include the Relay Node interface"

      def create_type_file
        template "object.erb", "#{options[:directory]}/types/#{type_file_name}.rb"
      end
    end
  end
end

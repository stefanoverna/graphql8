# frozen_string_literal: true
require 'generators/graphql8/type_generator'

module Graphql
  module Generators
    # Generate an interface type by name,
    # with the specified fields.
    #
    # ```
    # rails g graphql8:interface NamedEntityType name:String!
    # ```
    class InterfaceGenerator < TypeGeneratorBase
      desc "Create a GraphQL8::InterfaceType with the given name and fields"
      source_root File.expand_path('../templates', __FILE__)

      argument :fields,
        type: :array,
        default: [],
        banner: "name:type name:type ...",
        desc: "Fields for this interface (type may be expressed as Ruby or GraphQL8)"

      def create_type_file
        template "interface.erb", "#{options[:directory]}/types/#{type_file_name}.rb"
      end
    end
  end
end

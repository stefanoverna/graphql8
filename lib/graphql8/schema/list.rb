# frozen_string_literal: true

module GraphQL8
  class Schema
    # Represents a list type in the schema.
    # Wraps a {Schema::Member} as a list type.
    # @see {Schema::Member::TypeSystemHelpers#to_list_type}
    class List < GraphQL8::Schema::Wrapper
      def to_graphql
        @of_type.graphql_definition.to_list_type
      end

      # @return [GraphQL8::TypeKinds::LIST]
      def kind
        GraphQL8::TypeKinds::LIST
      end

      # @return [true]
      def list?
        true
      end

      def to_type_signature
        "[#{@of_type.to_type_signature}]"
      end
    end
  end
end

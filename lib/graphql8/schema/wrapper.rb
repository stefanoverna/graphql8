# frozen_string_literal: true

module GraphQL8
  class Schema
    class Wrapper
      include GraphQL8::Schema::Member::CachedGraphQL8Definition
      include GraphQL8::Schema::Member::TypeSystemHelpers

      # @return [Class, Module] The inner type of this wrapping type, the type of which one or more objects may be present.
      attr_reader :of_type

      def initialize(of_type)
        @of_type = of_type
      end

      def to_graphql
        raise NotImplementedError
      end

      def unwrap
        @of_type.unwrap
      end

      def ==(other)
        self.class == other.class && of_type == other.of_type
      end
    end
  end
end

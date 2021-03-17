# frozen_string_literal: true
module GraphQL8
  module Define
    # Wrap the object in NonNullType in response to `!`
    # @example required Int type
    #   !GraphQL8::INT_TYPE
    #
    module NonNullWithBang
      # Make the type non-null
      # @return [GraphQL8::NonNullType] a non-null type which wraps the original type
      def !
        to_non_null_type
      end
    end
  end
end

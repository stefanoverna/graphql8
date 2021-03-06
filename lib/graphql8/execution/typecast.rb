# frozen_string_literal: true
module GraphQL8
  module Execution
    # @api private
    module Typecast
      # @return [Boolean]
      def self.subtype?(parent_type, child_type)
        if parent_type == child_type
          # Equivalent types are subtypes
          true
        elsif child_type.is_a?(GraphQL8::NonNullType)
          # A non-null type is a subtype of a nullable type
          # if its inner type is a subtype of that type
          if parent_type.is_a?(GraphQL8::NonNullType)
            subtype?(parent_type.of_type, child_type.of_type)
          else
            subtype?(parent_type, child_type.of_type)
          end
        else
          case parent_type
          when GraphQL8::InterfaceType
            # A type is a subtype of an interface
            # if it implements that interface
            case child_type
            when GraphQL8::ObjectType
              child_type.interfaces.include?(parent_type)
            else
              false
            end
          when GraphQL8::UnionType
            # A type is a subtype of that union
            # if the union includes that type
            parent_type.possible_types.include?(child_type)
          when GraphQL8::ListType
            # A list type is a subtype of another list type
            # if its inner type is a subtype of the other inner type
            case child_type
            when GraphQL8::ListType
              subtype?(parent_type.of_type, child_type.of_type)
            else
              false
            end
          else
            false
          end
        end
      end
    end
  end
end

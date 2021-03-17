# frozen_string_literal: true
module GraphQL8
  class Schema
    module DefaultTypeError
      def self.call(type_error, ctx)
        case type_error
        when GraphQL8::InvalidNullError
          ctx.errors << type_error
        when GraphQL8::UnresolvedTypeError, GraphQL8::StringEncodingError
          raise type_error
        end
      end
    end
  end
end

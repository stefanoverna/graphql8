# frozen_string_literal: true
module GraphQL8
  class Schema
    # @api private
    module NullMask
      def self.call(member, ctx)
        false
      end
    end
  end
end

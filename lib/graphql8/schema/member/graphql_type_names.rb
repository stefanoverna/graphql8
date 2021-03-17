# frozen_string_literal: true

module GraphQL8
  class Schema
    class Member
      # These constants are interpreted as GraphQL8 types when defining fields or arguments
      #
      # @example
      #   field :is_draft, Boolean, null: false
      #   field :id, ID, null: false
      #   field :score, Int, null: false
      #
      # @api private
      module GraphQL8TypeNames
        Boolean = "Boolean"
        ID = "ID"
        Int = "Int"
      end
    end
  end
end

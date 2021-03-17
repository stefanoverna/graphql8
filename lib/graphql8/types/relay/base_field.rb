# frozen_string_literal: true

module GraphQL8
  module Types
    module Relay
      class BaseField < GraphQL8::Schema::Field
        def initialize(edge_class: nil, **rest, &block)
          @edge_class = edge_class
          super(**rest, &block)
        end

        def to_graphql
          field = super
          if @edge_class
            field.edge_class = @edge_class
          end
          field
        end
      end
    end
  end
end

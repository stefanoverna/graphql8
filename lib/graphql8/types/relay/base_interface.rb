# frozen_string_literal: true

module GraphQL8
  module Types
    module Relay
      module BaseInterface
        include GraphQL8::Schema::Interface

        field_class(Types::Relay::BaseField)

        definition_methods do
          def default_relay(new_value)
            @default_relay = new_value
          end

          def default_relay?
            !!@default_relay
          end

          def to_graphql
            type_defn = super
            type_defn.default_relay = default_relay?
            type_defn
          end
        end
      end
    end
  end
end

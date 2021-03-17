# frozen_string_literal: true
module GraphQL8
  module Introspection
    class TypeKindEnum < GraphQL8::Schema::Enum
      graphql_name "__TypeKind"
      description "An enum describing what kind of type a given `__Type` is."
      GraphQL8::TypeKinds::TYPE_KINDS.each do |type_kind|
        value(type_kind.name, type_kind.description)
      end
      introspection true
    end
  end
end

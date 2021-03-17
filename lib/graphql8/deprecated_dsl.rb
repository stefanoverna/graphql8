# frozen_string_literal: true
module GraphQL8
  # There are two ways to apply the deprecated `!` DSL to class-style schema definitions:
  #
  # 1. Scoped by file (CRuby only), add to the top of the file:
  #
  #      using GraphQL8::DeprecatedDSL
  #
  #   (This is a "refinement", there are also other ways to scope it.)
  #
  # 2. Global application, add before schema definition:
  #
  #      GraphQL8::DeprecatedDSL.activate
  #
  module DeprecatedDSL
    TYPE_CLASSES = [
      GraphQL8::Schema::Scalar,
      GraphQL8::Schema::Enum,
      GraphQL8::Schema::InputObject,
      GraphQL8::Schema::Union,
      GraphQL8::Schema::Interface,
      GraphQL8::Schema::Object,
    ]

    def self.activate
      TYPE_CLASSES.each { |c| c.extend(Methods) }
      GraphQL8::Schema::List.include(Methods)
      GraphQL8::Schema::NonNull.include(Methods)
    end
    module Methods
      def !
        to_non_null_type
      end
    end

    TYPE_CLASSES.each do |type_class|
      refine type_class.singleton_class do
        include Methods
      end
    end
  end
end

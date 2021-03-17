# frozen_string_literal: true
module GraphQL8
  module StaticValidation
    # Initialized with a {GraphQL8::Schema}, then it can validate {GraphQL8::Language::Nodes::Documents}s based on that schema.
    #
    # By default, it's used by {GraphQL8::Query}
    #
    # @example Validate a query
    #   validator = GraphQL8::StaticValidation::Validator.new(schema: MySchema)
    #   query = GraphQL8::Query.new(MySchema, query_string)
    #   errors = validator.validate(query)[:errors]
    #
    class Validator
      # @param schema [GraphQL8::Schema]
      # @param rules [Array<#validate(context)>] a list of rules to use when validating
      def initialize(schema:, rules: GraphQL8::StaticValidation::ALL_RULES)
        @schema = schema
        @rules = rules
      end

      # Validate `query` against the schema. Returns an array of message hashes.
      # @param query [GraphQL8::Query]
      # @return [Array<Hash>]
      def validate(query, validate: true)
        query.trace("validate", { validate: validate, query: query }) do
          context = GraphQL8::StaticValidation::ValidationContext.new(query)
          rewrite = GraphQL8::InternalRepresentation::Rewrite.new

          # Put this first so its enters and exits are always called
          rewrite.validate(context)

          # If the caller opted out of validation, don't attach these
          if validate
            @rules.each do |rules|
              rules.new.validate(context)
            end
          end

          context.visitor.visit
          rewrite_result = rewrite.document

          # Post-validation: allow validators to register handlers on rewritten query nodes
          GraphQL8::InternalRepresentation::Visit.visit_each_node(rewrite_result.operation_definitions, context.each_irep_node_handlers)

          {
            errors: context.errors,
            # If there were errors, the irep is garbage
            irep: context.errors.any? ? nil : rewrite_result,
          }
        end
      end
    end
  end
end

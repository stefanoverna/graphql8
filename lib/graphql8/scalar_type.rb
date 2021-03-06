# frozen_string_literal: true
module GraphQL8
  # # GraphQL8::ScalarType
  #
  # Scalars are plain values. They are leaf nodes in a GraphQL8 query tree.
  #
  # ## Built-in Scalars
  #
  # `GraphQL8` comes with standard built-in scalars:
  #
  # |Constant | `.define` helper|
  # |-------|--------|
  # |`GraphQL8::STRING_TYPE` | `types.String`|
  # |`GraphQL8::INT_TYPE` | `types.Int`|
  # |`GraphQL8::FLOAT_TYPE` | `types.Float`|
  # |`GraphQL8::ID_TYPE` | `types.ID`|
  # |`GraphQL8::BOOLEAN_TYPE` | `types.Boolean`|
  #
  # (`types` is an instance of `GraphQL8::Definition::TypeDefiner`; `.String`, `.Float`, etc are methods which return built-in scalars.)
  #
  # ## Custom Scalars
  #
  # You can define custom scalars for your GraphQL8 server. It requires some special functions:
  #
  # - `coerce_input` is used to prepare incoming values for GraphQL8 execution. (Incoming values come from variables or literal values in the query string.)
  # - `coerce_result` is used to turn Ruby values _back_ into serializable values for query responses.
  #
  # @example defining a type for Time
  #   TimeType = GraphQL8::ScalarType.define do
  #     name "Time"
  #     description "Time since epoch in seconds"
  #
  #     coerce_input ->(value, ctx) { Time.at(Float(value)) }
  #     coerce_result ->(value, ctx) { value.to_f }
  #   end
  #
  #
  # You can customize the error message for invalid input values by raising a `GraphQL8::CoercionError` within `coerce_input`:
  #
  # @example raising a custom error message
  #   TimeType = GraphQL8::ScalarType.define do
  #     name "Time"
  #     description "Time since epoch in seconds"
  #
  #     coerce_input ->(value, ctx) do
  #       begin
  #         Time.at(Float(value))
  #       rescue ArgumentError
  #         raise GraphQL8::CoercionError, "cannot coerce `#{value.inspect}` to Float"
  #       end
  #     end
  #
  #     coerce_result ->(value, ctx) { value.to_f }
  #   end
  #
  # This will result in the message of the `GraphQL8::CoercionError` being used in the error response:
  #
  # @example custom error response
  #   {"message"=>"cannot coerce `"2"` to Float", "locations"=>[{"line"=>3, "column"=>9}], "fields"=>["arg"]}
  #
  class ScalarType < GraphQL8::BaseType
    accepts_definitions :coerce, :coerce_input, :coerce_result
    ensure_defined :coerce_non_null_input, :coerce_result

    module NoOpCoerce
      def self.call(val, ctx)
        val
      end
    end

    def initialize
      super
      self.coerce = NoOpCoerce
    end

    def coerce=(proc)
      self.coerce_input = proc
      self.coerce_result = proc
    end

    def coerce_input=(coerce_input_fn)
      if !coerce_input_fn.nil?
        @coerce_input_proc = ensure_two_arg(coerce_input_fn, :coerce_input)
      end
    end

    def coerce_result(value, ctx = nil)
      if ctx.nil?
        warn_deprecated_coerce("coerce_isolated_result")
        ctx = GraphQL8::Query::NullContext
      end
      @coerce_result_proc.call(value, ctx)
    end

    def coerce_result=(coerce_result_fn)
      if !coerce_result_fn.nil?
        @coerce_result_proc = ensure_two_arg(coerce_result_fn, :coerce_result)
      end
    end

    def kind
      GraphQL8::TypeKinds::SCALAR
    end

    private

    def ensure_two_arg(callable, method_name)
      GraphQL8::BackwardsCompatibility.wrap_arity(callable, from: 1, to: 2, name: "#{name}.#{method_name}(val, ctx)")
    end

    def coerce_non_null_input(value, ctx)
      @coerce_input_proc.call(raw_coercion_input(value), ctx)
    end

    def raw_coercion_input(value)
      if value.is_a?(GraphQL8::Language::Nodes::InputObject)
        value.to_h
      elsif value.is_a?(Array)
        value.map { |element| raw_coercion_input(element) }
      elsif value.is_a?(GraphQL8::Language::Nodes::Enum)
        value.name
      else
        value
      end
    end

    def validate_non_null_input(value, ctx)
      result = Query::InputValidationResult.new
      if coerce_non_null_input(value, ctx).nil?
        result.add_problem("Could not coerce value #{GraphQL8::Language.serialize(value)} to #{name}")
      end
      result
    end
  end
end

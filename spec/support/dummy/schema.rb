# frozen_string_literal: true
require "graphql8"
require_relative "./data"
module Dummy
  class NoSuchDairyError < StandardError; end

  GraphQL8::Field.accepts_definitions(joins: GraphQL8::Define.assign_metadata_key(:joins))
  GraphQL8::BaseType.accepts_definitions(class_names: GraphQL8::Define.assign_metadata_key(:class_names))

  class BaseField < GraphQL8::Schema::Field
    accepts_definition :joins
  end

  module BaseInterface
    include GraphQL8::Schema::Interface
  end

  class BaseObject < GraphQL8::Schema::Object
    field_class BaseField
    accepts_definition :class_names
  end

  class BaseUnion < GraphQL8::Schema::Union
  end

  class BaseEnum < GraphQL8::Schema::Enum
  end

  class BaseInputObject < GraphQL8::Schema::InputObject
  end

  class BaseScalar < GraphQL8::Schema::Scalar
  end

  module LocalProduct
    include BaseInterface
    description "Something that comes from somewhere"
    field :origin, String, null: false,
      description: "Place the thing comes from"
  end

  module Edible
    include BaseInterface
    description "Something you can eat, yum"
    field :fat_content, Float, null: false, description: "Percentage which is fat"
    field :origin, String, null: false, description: "Place the edible comes from"
    field :self_as_edible, Edible, null: true
    def self_as_edible
      object
    end
  end

  module EdibleAsMilk
    include Edible
    description "Milk :+1:"
    def self.resolve_type(obj, ctx)
      Milk
    end
  end

  class DairyAnimal < BaseEnum
    description "An animal which can yield milk"
    value("COW",      "Animal with black and white spots", value: 1)
    value("DONKEY",   "Animal with fur", value: :donkey)
    value("GOAT",     "Animal with horns")
    value("REINDEER", "Animal with horns", value: 'reindeer')
    value("SHEEP",    "Animal with wool")
    value("YAK",      "Animal with long hair", deprecation_reason: "Out of fashion")
  end

  module AnimalProduct
    include BaseInterface
    description "Comes from an animal, no joke"
    field :source, DairyAnimal, "Animal which produced this product", null: false
  end

  class Cheese < BaseObject
    class_names ["Cheese"]
    description "Cultured dairy product"
    implements Edible
    implements EdibleAsMilk
    implements AnimalProduct
    implements LocalProduct

    field :id, Int, "Unique identifier", null: false
    field :flavor, String, "Kind of Cheese", null: false
    field :origin, String, "Place the cheese comes from", null: false

    field :source, DairyAnimal,
      "Animal which produced the milk for this cheese",
      null: false

    field :similar_cheese, Cheese, "Cheeses like this one", null: true  do
      # metadata test
      joins [:cheeses, :milks]
      argument :source, [DairyAnimal], required: true
      argument :nullableSource, [DairyAnimal], required: false, default_value: [1]
    end

    def similar_cheese(source:, nullable_source:)
      # get the strings out:
      sources = source
      if sources.include?("YAK")
        raise NoSuchDairyError.new("No cheeses are made from Yak milk!")
      else
        CHEESES.values.find { |cheese| sources.include?(cheese.source) }
      end
    end

    field :nullable_cheese, Cheese, "Cheeses like this one", null: true do
      argument :source, [DairyAnimal], required: false
    end
    def nullable_cheese; raise("NotImplemented"); end

    field :deeply_nullable_cheese, Cheese, "Cheeses like this one", null: true do
      argument :source, [[DairyAnimal, null: true], null: true], required: false
    end
    def deeply_nullable_cheese; raise("NotImplemented"); end

    # Keywords can be used for definition methods
    field :fat_content,
      type: GraphQL8::FLOAT_TYPE,
      null: false,
      description: "Percentage which is milkfat",
      deprecation_reason: "Diet fashion has changed"
  end

  class Milk < BaseObject
    description "Dairy beverage"
    implements Edible
    implements EdibleAsMilk
    implements AnimalProduct
    implements LocalProduct

    field :id, ID, null: false
    field :source, DairyAnimal, null: false, description: "Animal which produced this milk"
    field :origin, String, null: false, description: "Place the milk comes from"
    field :flavors, [String, null: true], null: true, description: "Chocolate, Strawberry, etc" do
      argument :limit, Int, required: false
    end

    def flavors(limit: nil)
      limit ? object.flavors.first(limit) : object.flavors
    end

    field :execution_error, String, null: true
    def execution_error; raise(GraphQL8::ExecutionError, "There was an execution error"); end

    field :all_dairy, ["Dummy::DairyProduct", null: true], null: true
    def all_dairy; CHEESES.values + MILKS.values; end
  end

  class Beverage < BaseUnion
    description "Something you can drink"
    possible_types Milk
  end

  module Sweetener
    include BaseInterface
    field :sweetness, Integer, null: true
  end

  # No actual data; This type is an "orphan", only accessible through Interfaces
  class Honey < BaseObject
    description "Sweet, dehydrated bee barf"
    field :flower_type, String, "What flower this honey came from", null: true
    implements Edible
    implements AnimalProduct
    implements Sweetener
  end

  class Dairy < BaseObject
    description "A farm where milk is harvested and cheese is produced"
    field :id, ID, null: false
    field :cheese, Cheese, null: true
    field :milks, [Milk, null: true], null: true
  end

  class MaybeNull < BaseObject
    description "An object whose fields return nil"
    field :cheese, Cheese, null: true
  end

  class TracingScalar < BaseObject
    description "An object which has traced scalars"

    field :trace_nil, Integer, null: true
    field :trace_false, Integer, null: true, trace: false
    field :trace_true, Integer, null: true, trace: true
  end

  class DairyProduct < BaseUnion
    description "Kinds of food made from milk"
    # Test that these forms of declaration still work:
    possible_types "Dummy::Milk", Cheese
  end

  class Cow < BaseObject
    description "A bovine animal that produces milk"
    field :id, ID, null: false
    field :name, String, null: true
    field :last_produced_dairy, DairyProduct, null: true

    field :cant_be_null_but_is, String, null: false
    def cant_be_null_but_is; nil; end

    field :cant_be_null_but_raises_execution_error, String, null: false
    def cant_be_null_but_raises_execution_error; raise(GraphQL8::ExecutionError, "BOOM"); end
  end

  class Goat < BaseObject
    description "An caprinae animal that produces milk"
    field :id, ID, null: false
    field :name, String, null: true
    field :last_produced_dairy, DairyProduct, null: true
  end

  class Animal < BaseUnion
    description "Species of living things"
    possible_types Cow, Goat
  end

  class AnimalAsCow < BaseUnion
    description "All animals go mooooo!"
    possible_types Cow
    def self.resolve_type(obj, ctx)
      Cow
    end
  end

  class ResourceOrder < BaseInputObject
    graphql_name "ResourceOrderType"
    description "Properties used to determine ordering"

    argument :direction, String, required: true, description: "ASC or DESC"
  end

  class DairyProductInput < BaseInputObject
    description "Properties for finding a dairy product"
    argument :source, DairyAnimal, required: true, description: "Where it came from"
    argument :origin_dairy, String, required: false, description: "Dairy which produced it", default_value: "Sugar Hollow Dairy"
    argument :fat_content, Float, required: false, description: "How much fat it has", default_value: 0.3
    argument :organic, Boolean, required: false, default_value: false
    argument :order_by, ResourceOrder, required: false, default_value: { direction: "ASC" }, camelize: false
  end

  class DeepNonNull < BaseObject
    field :non_null_int, Integer, null: false do
      argument :returning, Integer, required: false
    end
    def non_null_int(returning: nil)
      returning
    end

    field :deep_non_null, DeepNonNull, null: false
    def deep_non_null; :deep_non_null; end
  end

  class Time < BaseScalar
    description "Time since epoch in seconds"

    def self.coerce_input(value, ctx)
      Time.at(Float(value))
    rescue ArgumentError
      raise GraphQL8::CoercionError, 'cannot coerce to Float'
    end

    def self.coerce_result(value, ctx)
      value.to_f
    end
  end

  class FetchItem < GraphQL8::Function
    attr_reader :type, :description, :arguments

    def initialize(type:, data:, id_type: !GraphQL8::INT_TYPE)
      @type = type
      @data = data
      @description = "Find a #{type.name} by id"
      @arguments = self.class.arguments.merge({"id" => GraphQL8::Argument.define(name: "id", type: id_type)})
    end

    def call(obj, args, ctx)
      id_string = args["id"].to_s # Cheese has Int type, Milk has ID type :(
      _id, item = @data.find { |id, _item| id.to_s == id_string }
      item
    end
  end

  class GetSingleton < GraphQL8::Function
    attr_reader :description, :type

    def initialize(type:, data:)
      @description = "Find the only #{type.name}"
      @type = type
      @data = data
    end

    def call(obj, args, ctx)
      @data
    end
  end

  FavoriteFieldDefn = GraphQL8::Field.define do
    name "favoriteEdible"
    description "My favorite food"
    type Edible
    resolve ->(t, a, c) { MILKS[1] }
  end

  class DairyAppQuery < BaseObject
    graphql_name "Query"
    description "Query root of the system"
    # Returns `root_value:`
    field :root, String, null: true
    def root
      object
    end
    field :cheese, function: FetchItem.new(type: Cheese, data: CHEESES)
    field :milk, function: FetchItem.new(type: Milk, data: MILKS, id_type: GraphQL8::Types::ID.to_non_null_type)
    field :dairy, function: GetSingleton.new(type: Dairy, data: DAIRY)
    field :from_source, [Cheese, null: true], null: true, description: "Cheese from source" do
      argument :source, DairyAnimal, required: false, default_value: 1
    end
    def from_source(source:)
      CHEESES.values.select { |c| c.source == source }
    end

    field :favorite_edible, field: FavoriteFieldDefn
    field :cow, function: GetSingleton.new(type: Cow, data: COWS[1])
    field :search_dairy, DairyProduct, null: false do
      description "Find dairy products matching a description"
      # This is a list just for testing ????
      argument :product, [DairyProductInput, null: true], required: false, default_value: [{"source" => "SHEEP"}]
      argument :expires_after, Time, required: false
    end

    def search_dairy(product:, expires_after: nil)
      source = product[0][:source]
      products = CHEESES.values + MILKS.values
      if !source.nil?
        products = products.select { |pr| pr.source == source }
      end
      products.first
    end

    field :all_animal, [Animal, null: true], null: false
    def all_animal
      COWS.values + GOATS.values
    end

    field :all_animal_as_cow, [AnimalAsCow, null: true], null: false, method: :all_animal

    field :all_dairy, [DairyProduct, null: true], null: true do
      argument :execution_error_at_index, Integer, required: false
    end
    def all_dairy(execution_error_at_index: nil)
      result = CHEESES.values + MILKS.values
      if execution_error_at_index
        result[execution_error_at_index] = GraphQL8::ExecutionError.new("missing dairy")
      end
      result
    end

    field :all_edible, [Edible, null: true], null: true
    def all_edible
      CHEESES.values + MILKS.values
    end

    field :all_edible_as_milk, [EdibleAsMilk, null: true], null: true, method: :all_edible

    field :error, String, null: true, description: "Raise an error"
    def error
      raise("This error was raised on purpose")
    end

    field :execution_error, String, null: true
    def execution_error
      raise(GraphQL8::ExecutionError, "There was an execution error")
    end

    field :value_with_execution_error, Integer, null: false, extras: [:execution_errors]
    def value_with_execution_error(execution_errors:)
      execution_errors.add("Could not fetch latest value")
      0
    end

    field :multiple_errors_on_non_nullable_field, String, null: false
    def multiple_errors_on_non_nullable_field
      [
        GraphQL8::ExecutionError.new("This is an error message for some error."),
        GraphQL8::ExecutionError.new("This is another error message for a different error.")
      ]
    end

    field :execution_error_with_options, Integer, null: true
    def execution_error_with_options
      GraphQL8::ExecutionError.new("Permission Denied!", options: { "code" => "permission_denied" })
    end

    field :execution_error_with_extensions, Integer, null: true
    def execution_error_with_extensions
      GraphQL8::ExecutionError.new("Permission Denied!", extensions: { "code" => "permission_denied" })
    end

    # To test possibly-null fields
    field :maybe_null, MaybeNull, null: true
    def maybe_null
      OpenStruct.new(cheese: nil)
    end

    field :tracing_scalar, TracingScalar, null: true
    def tracing_scalar
      OpenStruct.new(
        trace_nil: 2,
        trace_false: 3,
        trace_true: 5,
      )
    end

    field :deep_non_null, DeepNonNull, null: false
    def deep_non_null; :deep_non_null; end
  end

  GLOBAL_VALUES = []

  class ReplaceValuesInput < BaseInputObject
    argument :values, [Integer], required: true
  end

  class DairyAppMutation < BaseObject
    graphql_name "Mutation"
    description "The root for mutations in this schema"
    field :push_value, [Integer], null: false, description: "Push a value onto a global array :D" do
      argument :value, Integer, required: true, as: :val
    end
    def push_value(val:)
      GLOBAL_VALUES << val
      GLOBAL_VALUES
    end

    field :replaceValues, [Integer], "Replace the global array with new values", null: false do
      argument :input, ReplaceValuesInput, required: true
    end

    def replace_values(input:)
      GLOBAL_VALUES.clear
      GLOBAL_VALUES.concat(input["values"])
      GLOBAL_VALUES
    end
  end

  class Subscription < BaseObject
    field :test, String, null: true
    def test; "Test"; end
  end

  class Schema < GraphQL8::Schema
    query DairyAppQuery
    mutation DairyAppMutation
    subscription Subscription
    max_depth 5
    # TODO why is `.graphql_definition` required here?
    orphan_types Honey, Beverage.graphql_definition

    rescue_from(NoSuchDairyError) { |err| err.message  }

    def self.resolve_type(type, obj, ctx)
      Schema.types[obj.class.name.split("::").last]
    end
  end
end

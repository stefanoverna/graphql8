# frozen_string_literal: true
require "graphql8/backtrace/inspect_result"
require "graphql8/backtrace/table"
require "graphql8/backtrace/traced_error"
require "graphql8/backtrace/tracer"
module GraphQL8
  # Wrap unhandled errors with {TracedError}.
  #
  # {TracedError} provides a GraphQL8 backtrace with arguments and return values.
  # The underlying error is available as {TracedError#cause}.
  #
  # WARNING: {.enable} is not threadsafe because {GraphQL8::Tracing.install} is not threadsafe.
  #
  # @example toggling backtrace annotation
  #   # to enable:
  #   GraphQL8::Backtrace.enable
  #   # later, to disable:
  #   GraphQL8::Backtrace.disable
  #
  class Backtrace
    include Enumerable
    extend Forwardable

    def_delegators :to_a, :each, :[]

    def self.enable
      warn("GraphQL8::Backtrace.enable is deprecated, add `use GraphQL8::Backtrace` to your schema definition instead.")
      GraphQL8::Tracing.install(Backtrace::Tracer)
      nil
    end

    def self.disable
      GraphQL8::Tracing.uninstall(Backtrace::Tracer)
      nil
    end

    def self.use(schema_defn)
      schema_defn.tracer(self::Tracer)
    end

    def initialize(context, value: nil)
      @table = Table.new(context, value: value)
    end

    def inspect
      @table.to_table
    end

    alias :to_s :inspect

    def to_a
      @table.to_backtrace
    end
  end
end

# frozen_string_literal: true
module GraphQL8
  module Execution
    # Lookahead creates a uniform interface to inspect the forthcoming selections.
    #
    # It assumes that the AST it's working with is valid. (So, it's safe to use
    # during execution, but if you're using it directly, be sure to validate first.)
    #
    # A field may get access to its lookahead by adding `extras: [:lookahead]`
    # to its configuration.
    #
    # __NOTE__: Lookahead for typed fragments (eg `node { ... on Thing { ... } }`)
    # hasn't been implemented yet. It's possible, I just didn't need it yet.
    # Feel free to open a PR or an issue if you want to add it.
    #
    # @example looking ahead in a field
    #   field :articles, [Types::Article], null: false,
    #     extras: [:lookahead]
    #
    #   # For example, imagine a faster database call
    #   # may be issued when only some fields are requested.
    #   #
    #   # Imagine that _full_ fetch must be made to satisfy `fullContent`,
    #   # we can look ahead to see if we need that field. If we do,
    #   # we make the expensive database call instead of the cheap one.
    #   def articles(lookahead:)
    #     if lookahead.selects?(:full_content)
    #       fetch_full_articles(object)
    #     else
    #       fetch_preview_articles(object)
    #     end
    #   end
    class Lookahead
      # @param query [GraphQL8::Query]
      # @param ast_nodes [Array<GraphQL8::Language::Nodes::Field>, Array<GraphQL8::Language::Nodes::OperationDefinition>]
      # @param field [GraphQL8::Schema::Field] if `ast_nodes` are fields, this is the field definition matching those nodes
      # @param root_type [Class] if `ast_nodes` are operation definition, this is the root type for that operation
      def initialize(query:, ast_nodes:, field: nil, root_type: nil)
        @ast_nodes = ast_nodes
        @field = field
        @root_type = root_type
        @query = query
      end

      # True if this node has a selection on `field_name`.
      # If `field_name` is a String, it is treated as a GraphQL8-style (camelized)
      # field name and used verbatim. If `field_name` is a Symbol, it is
      # treated as a Ruby-style (underscored) name and camelized before comparing.
      #
      # If `arguments:` is provided, each provided key/value will be matched
      # against the arguments in the next selection. This method will return false
      # if any of the given `arguments:` are not present and matching in the next selection.
      # (But, the next selection may contain _more_ than the given arguments.)
      # @param field_name [String, Symbol]
      # @param arguments [Hash] Arguments which must match in the selection
      # @return [Boolean]
      def selects?(field_name, arguments: nil)
        selection(field_name, arguments: arguments).selected?
      end

      # @return [Boolean] True if this lookahead represents a field that was requested
      def selected?
        true
      end

      # Like {#selects?}, but can be used for chaining.
      # It returns a null object (check with {#selected?})
      # @return [GraphQL8::Execution::Lookahead]
      def selection(field_name, arguments: nil)
        next_field_name = normalize_name(field_name)

        next_field_owner = if @field
          @field.type.unwrap
        else
          @root_type
        end

        next_field_defn = FieldHelpers.get_field(@query.schema, next_field_owner, next_field_name)
        if next_field_defn
          next_nodes = []
          @ast_nodes.each do |ast_node|
            ast_node.selections.each do |selection|
              find_selected_nodes(selection, next_field_name, next_field_defn, arguments: arguments, matches: next_nodes)
            end
          end

          if next_nodes.any?
            Lookahead.new(query: @query, ast_nodes: next_nodes, field: next_field_defn)
          else
            NULL_LOOKAHEAD
          end
        else
          NULL_LOOKAHEAD
        end
      end

      # Like {#selection}, but for all nodes.
      # It returns a list of Lookaheads for all Selections
      #
      # If `arguments:` is provided, each provided key/value will be matched
      # against the arguments in each selection. This method will filter the selections
      # if any of the given `arguments:` do not match the given selection.
      #
      # @example getting the name of a selection
      #   def articles(lookahead:)
      #     next_lookaheads = lookahead.selections # => [#<GraphQL8::Execution::Lookahead ...>, ...]
      #     next_lookaheads.map(&:name) #=> [:full_content, :title]
      #   end
      #
      # @param arguments [Hash] Arguments which must match in the selection
      # @return [Array<GraphQL8::Execution::Lookahead>]
      def selections(arguments: nil)
        subselections_by_name = {}
        @ast_nodes.each do |node|
          node.selections.each do |subselection|
            subselections_by_name[subselection.name] ||= selection(subselection.name, arguments: arguments)
          end
        end

        # Items may be filtered out if `arguments` doesn't match
        subselections_by_name.values.select(&:selected?)
      end

      # The method name of the field.
      # It returns the method_sym of the Lookahead's field.
      #
      # @example getting the name of a selection
      #   def articles(lookahead:)
      #     article.selection(:full_content).name # => :full_content
      #     # ...
      #   end
      #
      # @return [Symbol]
      def name
        return unless @field.respond_to?(:original_name)

        @field.original_name
      end

      # This is returned for {Lookahead#selection} when a non-existent field is passed
      class NullLookahead < Lookahead
        # No inputs required here.
        def initialize
        end

        def selected?
          false
        end

        def selects?(*)
          false
        end

        def selection(*)
          NULL_LOOKAHEAD
        end

        def selections(*)
          []
        end
      end

      # A singleton, so that misses don't come with overhead.
      NULL_LOOKAHEAD = NullLookahead.new

      private

      # If it's a symbol, stringify and camelize it
      def normalize_name(name)
        if name.is_a?(Symbol)
          Schema::Member::BuildType.camelize(name.to_s)
        else
          name
        end
      end

      def normalize_keyword(keyword)
        if keyword.is_a?(String)
          Schema::Member::BuildType.underscore(keyword).to_sym
        else
          keyword
        end
      end

      # If a selection on `node` matches `field_name` (which is backed by `field_defn`)
      # and matches the `arguments:` constraints, then add that node to `matches`
      def find_selected_nodes(node, field_name, field_defn, arguments:, matches:)
        case node
        when GraphQL8::Language::Nodes::Field
          if node.name == field_name
            if arguments.nil? || arguments.none?
              # No constraint applied
              matches << node
            else
              query_kwargs = ArgumentHelpers.arguments(@query, nil, field_defn, node)
              passes_args = arguments.all? do |arg_name, arg_value|
                arg_name = normalize_keyword(arg_name)
                # Make sure the constraint is present with a matching value
                query_kwargs.key?(arg_name) && query_kwargs[arg_name] == arg_value
              end
              if passes_args
                matches << node
              end
            end
          end
        when GraphQL8::Language::Nodes::InlineFragment
          node.selections.find { |s| find_selected_nodes(s, field_name, field_defn, arguments: arguments, matches: matches) }
        when GraphQL8::Language::Nodes::FragmentSpread
          frag_defn = @query.fragments[node.name]
          frag_defn.selections.find { |s| find_selected_nodes(s, field_name, field_defn, arguments: arguments, matches: matches) }
        else
          raise "Unexpected selection comparison on #{node.class.name} (#{node})"
        end
      end

      # TODO Dedup with interpreter
      module ArgumentHelpers
        module_function

        def arguments(query, graphql_object, arg_owner, ast_node)
          kwarg_arguments = {}
          arg_defns = arg_owner.arguments
          ast_node.arguments.each do |arg|
            arg_defn = arg_defns[arg.name] || raise("Invariant: missing argument definition for #{arg.name.inspect} in #{arg_defns.keys} from #{arg_owner}")
            # Need to distinguish between client-provided `nil`
            # and nothing-at-all
            is_present, value = arg_to_value(query, graphql_object, arg_defn.type, arg.value)
            if is_present
              # This doesn't apply to directives, which are legacy
              # Can remove this when Skip and Include use classes or something.
              if graphql_object
                value = arg_defn.prepare_value(graphql_object, value)
              end
              kwarg_arguments[arg_defn.keyword] = value
            end
          end
          arg_defns.each do |name, arg_defn|
            if arg_defn.default_value? && !kwarg_arguments.key?(arg_defn.keyword)
              kwarg_arguments[arg_defn.keyword] = arg_defn.default_value
            end
          end
          kwarg_arguments
        end

        # Get a Ruby-ready value from a client query.
        # @param graphql_object [Object] The owner of the field whose argument this is
        # @param arg_type [Class, GraphQL8::Schema::NonNull, GraphQL8::Schema::List]
        # @param ast_value [GraphQL8::Language::Nodes::VariableIdentifier, String, Integer, Float, Boolean]
        # @return [Array(is_present, value)]
        def arg_to_value(query, graphql_object, arg_type, ast_value)
          if ast_value.is_a?(GraphQL8::Language::Nodes::VariableIdentifier)
            # If it's not here, it will get added later
            if query.variables.key?(ast_value.name)
              return true, query.variables[ast_value.name]
            else
              return false, nil
            end
          elsif ast_value.is_a?(GraphQL8::Language::Nodes::NullValue)
            return true, nil
          elsif arg_type.is_a?(GraphQL8::Schema::NonNull)
            arg_to_value(query, graphql_object, arg_type.of_type, ast_value)
          elsif arg_type.is_a?(GraphQL8::Schema::List)
            # Treat a single value like a list
            arg_value = Array(ast_value)
            list = []
            arg_value.map do |inner_v|
              _present, value = arg_to_value(query, graphql_object, arg_type.of_type, inner_v)
              list << value
            end
            return true, list
          elsif arg_type.is_a?(Class) && arg_type < GraphQL8::Schema::InputObject
            # For these, `prepare` is applied during `#initialize`.
            # Pass `nil` so it will be skipped in `#arguments`.
            # What a mess.
            args = arguments(query, nil, arg_type, ast_value)
            # We're not tracking defaults_used, but for our purposes
            # we compare the value to the default value.
            return true, arg_type.new(ruby_kwargs: args, context: query.context, defaults_used: nil)
          else
            flat_value = flatten_ast_value(query, ast_value)
            return true, arg_type.coerce_input(flat_value, query.context)
          end
        end

        def flatten_ast_value(query, v)
          case v
          when GraphQL8::Language::Nodes::Enum
            v.name
          when GraphQL8::Language::Nodes::InputObject
            h = {}
            v.arguments.each do |arg|
              h[arg.name] = flatten_ast_value(query, arg.value)
            end
            h
          when Array
            v.map { |v2| flatten_ast_value(query, v2) }
          when GraphQL8::Language::Nodes::VariableIdentifier
            flatten_ast_value(query.variables[v.name])
          else
            v
          end
        end
      end

      # TODO dedup with interpreter
      module FieldHelpers
        module_function

        def get_field(schema, owner_type, field_name )
          field_defn = owner_type.get_field(field_name)
          field_defn ||= if owner_type == schema.query.metadata[:type_class] && (entry_point_field = schema.introspection_system.entry_point(name: field_name))
            entry_point_field.metadata[:type_class]
          elsif (dynamic_field = schema.introspection_system.dynamic_field(name: field_name))
            dynamic_field.metadata[:type_class]
          else
            raise "Invariant: no field for #{owner_type}.#{field_name}"
          end

          field_defn
        end
      end
    end
  end
end

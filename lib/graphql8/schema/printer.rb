# frozen_string_literal: true
module GraphQL8
  class Schema
    # Used to convert your {GraphQL8::Schema} to a GraphQL8 schema string
    #
    # @example print your schema to standard output (via helper)
    #   MySchema = GraphQL8::Schema.define(query: QueryType)
    #   puts GraphQL8::Schema::Printer.print_schema(MySchema)
    #
    # @example print your schema to standard output
    #   MySchema = GraphQL8::Schema.define(query: QueryType)
    #   puts GraphQL8::Schema::Printer.new(MySchema).print_schema
    #
    # @example print a single type to standard output
    #   query_root = GraphQL8::ObjectType.define do
    #     name "Query"
    #     description "The query root of this schema"
    #
    #     field :post do
    #       type post_type
    #       resolve ->(obj, args, ctx) { Post.find(args["id"]) }
    #     end
    #   end
    #
    #   post_type = GraphQL8::ObjectType.define do
    #     name "Post"
    #     description "A blog post"
    #
    #     field :id, !types.ID
    #     field :title, !types.String
    #     field :body, !types.String
    #   end
    #
    #   MySchema = GraphQL8::Schema.define(query: query_root)
    #
    #   printer = GraphQL8::Schema::Printer.new(MySchema)
    #   puts printer.print_type(post_type)
    #
    class Printer < GraphQL8::Language::Printer
      attr_reader :schema, :warden

      # @param schema [GraphQL8::Schema]
      # @param context [Hash]
      # @param only [<#call(member, ctx)>]
      # @param except [<#call(member, ctx)>]
      # @param introspection [Boolean] Should include the introspection types in the string?
      def initialize(schema, context: nil, only: nil, except: nil, introspection: false)
        @document_from_schema = GraphQL8::Language::DocumentFromSchemaDefinition.new(
          schema,
          context: context,
          only: only,
          except: except,
          include_introspection_types: introspection,
        )

        @document = @document_from_schema.document

        @schema = schema
      end

      # Return the GraphQL8 schema string for the introspection type system
      def self.print_introspection_schema
        query_root = ObjectType.define(name: "Root")
        schema = GraphQL8::Schema.define(query: query_root)

        introspection_schema_ast = GraphQL8::Language::DocumentFromSchemaDefinition.new(
          schema,
          except: ->(member, _) { member.name == "Root" },
          include_introspection_types: true,
          include_built_in_directives: true,
        ).document

        introspection_schema_ast.to_query_string(printer: IntrospectionPrinter.new)
      end

      # Return a GraphQL8 schema string for the defined types in the schema
      # @param schema [GraphQL8::Schema]
      # @param context [Hash]
      # @param only [<#call(member, ctx)>]
      # @param except [<#call(member, ctx)>]
      def self.print_schema(schema, **args)
        printer = new(schema, **args)
        printer.print_schema
      end

      # Return a GraphQL8 schema string for the defined types in the schema
      def print_schema
        print(@document)
      end

      def print_type(type)
        node = @document_from_schema.build_type_definition_node(type)
        print(node)
      end

      def print_directive(directive)
        if directive.name == "deprecated"
          reason = directive.arguments.find { |arg| arg.name == "reason" }

          if reason.value == GraphQL8::Directive::DEFAULT_DEPRECATION_REASON
            "@deprecated"
          else
            "@deprecated(reason: #{reason.value.to_s.inspect})"
          end
        else
          super
        end
      end

      class IntrospectionPrinter < GraphQL8::Language::Printer
        def print_schema_definition(schema)
          "schema {\n  query: Root\n}"
        end
      end
    end
  end
end

# frozen_string_literal: true
module GraphQL8
  class Schema
    class Member
      # @api private
      module BuildType
        LIST_TYPE_ERROR = "Use an array of [T] or [T, null: true] for list types; other arrays are not supported"

        module_function
        # @param type_expr [String, Class, GraphQL8::BaseType]
        # @return [GraphQL8::BaseType]
        def parse_type(type_expr, null:)
          list_type = false

          return_type = case type_expr
          when String
            case type_expr
            when "String"
              GraphQL8::Types::String
            when "Int", "Integer"
              GraphQL8::Types::Int
            when "Float"
              GraphQL8::Types::Float
            when "Boolean"
              GraphQL8::Types::Boolean
            when "ID"
              GraphQL8::Types::ID
            when /\A\[.*\]\Z/
              list_type = true
              # List members are required by default
              parse_type(type_expr[1..-2], null: false)
            when /.*!\Z/
              null = false
              parse_type(type_expr[0..-2], null: true)
            else
              maybe_type = constantize(type_expr)
              case maybe_type
              when GraphQL8::BaseType
                maybe_type
              when Module
                # This is a way to check that it's the right kind of module:
                if maybe_type.respond_to?(:graphql_definition)
                  maybe_type
                else
                  raise ArgumentError, "Unexpected class/module found for GraphQL8 type: #{type_expr} (must be type definition class/module)"
                end
              end
            end
          when GraphQL8::BaseType, GraphQL8::Schema::LateBoundType
            type_expr
          when Array
            case type_expr.length
            when 1
              list_type = true
              # List members are required by default
              parse_type(type_expr.first, null: false)
            when 2
              inner_type, nullable_option = type_expr
              if nullable_option.keys != [:null] || nullable_option.values != [true]
                raise ArgumentError, LIST_TYPE_ERROR
              end
              list_type = true
              parse_type(inner_type, null: true)
            else
              raise ArgumentError, LIST_TYPE_ERROR
            end
          when Module
            # This is a way to check that it's the right kind of module:
            if type_expr.respond_to?(:graphql_definition)
              type_expr
            else
              # Eg `String` => GraphQL8::STRING_TYPE
              parse_type(type_expr.name, null: true)
            end
          when false
            raise ArgumentError, "Received `false` instead of a type, maybe a `!` should be replaced with `null: true` (for fields) or `required: true` (for arguments)"
          end

          if return_type.nil?
            raise "Unexpected type input: #{type_expr} (#{type_expr.class})"
          end

          # Apply list_type first, that way the
          # .to_non_null_type applies to the list type, not the inner type
          if list_type
            return_type = return_type.to_list_type
          end

          if !null
            return_type = return_type.to_non_null_type
          end


          return_type
        end

        def to_type_name(something)
          case something
          when GraphQL8::BaseType, GraphQL8::Schema::LateBoundType
            something.unwrap.name
          when Array
            to_type_name(something.first)
          when Module
            if something.respond_to?(:graphql_name)
              something.graphql_name
            else
              to_type_name(something.name)
            end
          when String
            something.gsub(/\]\[\!/, "").split("::").last
          when GraphQL8::Schema::NonNull, GraphQL8::Schema::List
            to_type_name(something.unwrap)
          else
            raise "Unhandled to_type_name input: #{something} (#{something.class})"
          end
        end

        def camelize(string)
          return string unless string.include?("_")
          camelized = string.split('_').map(&:capitalize).join
          camelized[0] = camelized[0].downcase
          if (match_data = string.match(/\A(_+)/))
            camelized = "#{match_data[0]}#{camelized}"
          end
          camelized
        end

        # Resolves constant from string (based on Rails `ActiveSupport::Inflector.constantize`)
        def constantize(string)
          names = string.split('::')

          # Trigger a built-in NameError exception including the ill-formed constant in the message.
          Object.const_get(string) if names.empty?

          # Remove the first blank element in case of '::ClassName' notation.
          names.shift if names.size > 1 && names.first.empty?

          names.inject(Object) do |constant, name|
            if constant == Object
              constant.const_get(name)
            else
              candidate = constant.const_get(name)
              next candidate if constant.const_defined?(name, false)
              next candidate unless Object.const_defined?(name)

              # Go down the ancestors to check if it is owned directly. The check
              # stops when we reach Object or the end of ancestors tree.
              constant = constant.ancestors.inject do |const, ancestor|
                break const    if ancestor == Object
                break ancestor if ancestor.const_defined?(name, false)
                const
              end

              # Owner is in Object, so raise.
              constant.const_get(name, false)
            end
          end
        end

        def underscore(string)
          string
            .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2') # URLDecoder -> URL_Decoder
            .gsub(/([a-z\d])([A-Z])/,'\1_\2')     # someThing -> some_Thing
            .downcase
        end
      end
    end
  end
end
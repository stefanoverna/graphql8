# frozen_string_literal: true
module GraphQL8
  class Schema
    class Member
      module HasArguments
        def self.included(cls)
          cls.extend(ArgumentClassAccessor)
        end

        def self.extended(cls)
          cls.extend(ArgumentClassAccessor)
        end

        # @see {GraphQL8::Schema::Argument#initialize} for parameters
        # @return [GraphQL8::Schema::Argument] An instance of {arguments_class}, created from `*args`
        def argument(*args, **kwargs, &block)
          kwargs[:owner] = self
          arg_defn = self.argument_class.new(*args, **kwargs, &block)
          add_argument(arg_defn)
        end

        # Register this argument with the class.
        # @param arg_defn [GraphQL8::Schema::Argument]
        # @return [GraphQL8::Schema::Argument]
        def add_argument(arg_defn)
          own_arguments[arg_defn.name] = arg_defn
          arg_defn
        end

        # @return [Hash<String => GraphQL8::Schema::Argument] Arguments defined on this thing, keyed by name. Includes inherited definitions
        def arguments
          inherited_arguments = ((self.is_a?(Class) && superclass.respond_to?(:arguments)) ? superclass.arguments : {})
          # Local definitions override inherited ones
          inherited_arguments.merge(own_arguments)
        end

        # @param new_arg_class [Class] A class to use for building argument definitions
        def argument_class(new_arg_class = nil)
          self.class.argument_class(new_arg_class)
        end

        module ArgumentClassAccessor
          def argument_class(new_arg_class = nil)
            if new_arg_class
              @argument_class = new_arg_class
            else
              @argument_class || (superclass.respond_to?(:argument_class) ? superclass.argument_class : GraphQL8::Schema::Argument)
            end
          end
        end

        def own_arguments
          @own_arguments ||= {}
        end
      end
    end
  end
end

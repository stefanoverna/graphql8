# frozen_string_literal: true

module GraphQL8
  class Schema
    class Object < GraphQL8::Schema::Member
      extend GraphQL8::Schema::Member::AcceptsDefinition
      extend GraphQL8::Schema::Member::HasFields

      # @return [Object] the application object this type is wrapping
      attr_reader :object

      # @return [GraphQL8::Query::Context] the context instance for this query
      attr_reader :context

      class << self
        # This is protected so that we can be sure callers use the public method, {.authorized_new}
        # @see authorized_new to make instances
        protected :new

        # Make a new instance of this type _if_ the auth check passes,
        # otherwise, raise an error.
        #
        # Probably only the framework should call this method.
        #
        # This might return a {GraphQL8::Execution::Lazy} if the user-provided `.authorized?`
        # hook returns some lazy value (like a Promise).
        #
        # The reason that the auth check is in this wrapper method instead of {.new} is because
        # of how it might return a Promise. It would be weird if `.new` returned a promise;
        # It would be a headache to try to maintain Promise-y state inside a {Schema::Object}
        # instance. So, hopefully this wrapper method will do the job.
        #
        # @param object [Object] The thing wrapped by this object
        # @param context [GraphQL8::Query::Context]
        # @return [GraphQL8::Schema::Object, GraphQL8::Execution::Lazy]
        # @raise [GraphQL8::UnauthorizedError] if the user-provided hook returns `false`
        def authorized_new(object, context)
          context.schema.after_lazy(authorized?(object, context)) do |is_authorized|
            if is_authorized
              self.new(object, context)
            else
              # It failed the authorization check, so go to the schema's authorized object hook
              err = GraphQL8::UnauthorizedError.new(object: object, type: self, context: context)
              # If a new value was returned, wrap that instead of the original value
              new_obj = context.schema.unauthorized_object(err)
              if new_obj
                self.new(new_obj, context)
              end
            end
          end
        end
      end

      def initialize(object, context)
        @object = object
        @context = context
      end

      class << self
        def implements(*new_interfaces)
          new_interfaces.each do |int|
            if int.is_a?(Module)
              unless int.include?(GraphQL8::Schema::Interface)
                raise "#{int} cannot be implemented since it's not a GraphQL8 Interface. Use `include` for plain Ruby modules."
              end

              # Include the methods here,
              # `.fields` will use the inheritance chain
              # to find inherited fields
              include(int)
            end
          end
          own_interfaces.concat(new_interfaces)
        end

        def interfaces
          own_interfaces + (superclass <= GraphQL8::Schema::Object ? superclass.interfaces : [])
        end

        def own_interfaces
          @own_interfaces ||= []
        end

        # Include legacy-style interfaces, too
        def fields
          all_fields = super
          interfaces.each do |int|
            if int.is_a?(GraphQL8::InterfaceType)
              int_f = {}
              int.fields.each do |name, legacy_field|
                int_f[name] = field_class.from_options(name, field: legacy_field)
              end
              all_fields = int_f.merge(all_fields)
            end
          end
          all_fields
        end

        # @return [GraphQL8::ObjectType]
        def to_graphql
          obj_type = GraphQL8::ObjectType.new
          obj_type.name = graphql_name
          obj_type.description = description
          obj_type.interfaces = interfaces
          obj_type.introspection = introspection
          obj_type.mutation = mutation
          fields.each do |field_name, field_inst|
            field_defn = field_inst.to_graphql
            obj_type.fields[field_defn.name] = field_defn
          end

          obj_type.metadata[:type_class] = self

          obj_type
        end

        def kind
          GraphQL8::TypeKinds::OBJECT
        end
      end
    end
  end
end

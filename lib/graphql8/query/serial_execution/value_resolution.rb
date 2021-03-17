# frozen_string_literal: true
module GraphQL8
  class Query
    class SerialExecution
      module ValueResolution
        def self.resolve(parent_type, field_defn, field_type, value, selection, query_ctx)
          if value.nil? || value.is_a?(GraphQL8::ExecutionError)
            if field_type.kind.non_null?
              if value.nil?
                type_error = GraphQL8::InvalidNullError.new(parent_type, field_defn, value)
                query_ctx.schema.type_error(type_error, query_ctx)
              end
              raise GraphQL8::Query::Executor::PropagateNull
            else
              nil
            end
          else
            case field_type.kind
            when GraphQL8::TypeKinds::SCALAR, GraphQL8::TypeKinds::ENUM
              field_type.coerce_result(value, query_ctx)
            when GraphQL8::TypeKinds::LIST
              wrapped_type = field_type.of_type
              result = []
              i = 0
              value.each do |inner_value|
                inner_ctx = query_ctx.spawn_child(
                  key: i,
                  object: inner_value,
                  irep_node: selection,
                )

                result << resolve(
                  parent_type,
                  field_defn,
                  wrapped_type,
                  inner_value,
                  selection,
                  inner_ctx,
                )
                i += 1
              end
              result
            when GraphQL8::TypeKinds::NON_NULL
              wrapped_type = field_type.of_type
              resolve(
                parent_type,
                field_defn,
                wrapped_type,
                value,
                selection,
                query_ctx,
              )
            when GraphQL8::TypeKinds::OBJECT
              query_ctx.execution_strategy.selection_resolution.resolve(
                value,
                field_type,
                selection,
                query_ctx
              )
            when GraphQL8::TypeKinds::UNION, GraphQL8::TypeKinds::INTERFACE
              query = query_ctx.query
              resolved_type = query.resolve_type(value)
              possible_types = query.possible_types(field_type)

              if !possible_types.include?(resolved_type)
                type_error = GraphQL8::UnresolvedTypeError.new(value, field_defn, parent_type, resolved_type, possible_types)
                query.schema.type_error(type_error, query_ctx)
                raise GraphQL8::Query::Executor::PropagateNull
              else
                resolve(
                  parent_type,
                  field_defn,
                  resolved_type,
                  value,
                  selection,
                  query_ctx,
                )
              end
            else
              raise("Unknown type kind: #{field_type.kind}")
            end
          end
        end
      end
    end
  end
end

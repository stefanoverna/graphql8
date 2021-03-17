# frozen_string_literal: true
# test_via: ../backtrace.rb
module GraphQL8
  class Backtrace
    module InspectResult
      module_function

      def inspect_result(obj)
        case obj
        when Hash
          "{" +
            obj.map do |key, val|
              "#{key}: #{inspect_truncated(val)}"
            end.join(", ") +
            "}"
        when Array
          "[" +
            obj.map { |v| inspect_truncated(v) }.join(", ") +
            "]"
        when Query::Context::SharedMethods
          if obj.invalid_null?
            "nil"
          else
            inspect_truncated(obj.value)
          end
        else
          inspect_truncated(obj)
        end
      end

      def inspect_truncated(obj)
        case obj
        when Hash
          "{...}"
        when Array
          "[...]"
        when Query::Context::SharedMethods
          if obj.invalid_null?
            "nil"
          else
            inspect_truncated(obj.value)
          end
        when GraphQL8::Execution::Lazy
          "(unresolved)"
        else
          "#{obj.inspect}"
        end
      end
    end
  end
end

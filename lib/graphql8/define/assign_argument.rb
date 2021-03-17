# frozen_string_literal: true
module GraphQL8
  module Define
    # Turn argument configs into a {GraphQL8::Argument}.
    module AssignArgument
      def self.call(target, *args, **kwargs, &block)
        argument = GraphQL8::Argument.from_dsl(*args, **kwargs, &block)
        target.arguments[argument.name] = argument
      end
    end
  end
end

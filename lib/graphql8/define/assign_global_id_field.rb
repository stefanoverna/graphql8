# frozen_string_literal: true
module GraphQL8
  module Define
    module AssignGlobalIdField
      def self.call(type_defn, field_name)
        resolve = GraphQL8::Relay::GlobalIdResolve.new(type: type_defn)
        GraphQL8::Define::AssignObjectField.call(type_defn, field_name, type: GraphQL8::ID_TYPE.to_non_null_type, resolve: resolve)
      end
    end
  end
end

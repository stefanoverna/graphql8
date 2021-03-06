# frozen_string_literal: true
module GraphQL8
  class Query
    # This object can be `ctx` in places where there is no query
    class NullContext
      class NullWarden < GraphQL8::Schema::Warden
        def visible?(t); true; end
        def visible_field?(t); true; end
        def visible_type?(t); true; end
      end

      attr_reader :schema, :query, :warden

      def initialize
        @query = nil
        @schema = GraphQL8::Schema.new
        @warden = NullWarden.new(
          GraphQL8::Filter.new,
          context: self,
          schema: @schema,
        )
      end

      class << self
        extend Forwardable

        def instance
          @instance = self.new
        end

        def_delegators :instance, :query, :schema, :warden
      end
    end
  end
end

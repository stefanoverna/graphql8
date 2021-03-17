# frozen_string_literal: true
module GraphQL8
  module Introspection
    class DirectiveLocationEnum < GraphQL8::Schema::Enum
      graphql_name "__DirectiveLocation"
      description "A Directive can be adjacent to many parts of the GraphQL8 language, "\
                  "a __DirectiveLocation describes one such possible adjacencies."

      GraphQL8::Directive::LOCATIONS.each do |location|
        value(location.to_s, GraphQL8::Directive::LOCATION_DESCRIPTIONS[location], value: location)
      end
      introspection true
    end
  end
end

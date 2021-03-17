# frozen_string_literal: true
GraphQL8::Directive::DeprecatedDirective = GraphQL8::Directive.define do
  name "deprecated"
  description "Marks an element of a GraphQL schema as no longer supported."
  locations([GraphQL8::Directive::FIELD_DEFINITION, GraphQL8::Directive::ENUM_VALUE])

  reason_description = "Explains why this element was deprecated, usually also including a "\
    "suggestion for how to access supported similar data. Formatted "\
    "in [Markdown](https://daringfireball.net/projects/markdown/)."

  argument :reason, GraphQL8::STRING_TYPE, reason_description, default_value: GraphQL8::Directive::DEFAULT_DEPRECATION_REASON
  default_directive true
end

# frozen_string_literal: true
GraphQL8::Directive::IncludeDirective = GraphQL8::Directive.define do
  name "include"
  description "Directs the executor to include this field or fragment only when the `if` argument is true."
  locations([GraphQL8::Directive::FIELD, GraphQL8::Directive::FRAGMENT_SPREAD, GraphQL8::Directive::INLINE_FRAGMENT])
  argument :if, !GraphQL8::BOOLEAN_TYPE, 'Included when true.'
  default_directive true
end

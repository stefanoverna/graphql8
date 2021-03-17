# frozen_string_literal: true
GraphQL8::Directive::SkipDirective = GraphQL8::Directive.define do
  name "skip"
  description "Directs the executor to skip this field or fragment when the `if` argument is true."
  locations([GraphQL8::Directive::FIELD, GraphQL8::Directive::FRAGMENT_SPREAD, GraphQL8::Directive::INLINE_FRAGMENT])

  argument :if, !GraphQL8::BOOLEAN_TYPE, 'Skipped when true.'
  default_directive true
end

---
layout: guide
doc_stub: false
search: true
title: Introspection
section: Schema
desc: GraphQL8 has an introspection system that tells about the schema.
class_based_api: true
index: 2
---

A GraphQL8 schema has a [built-in introspection system](http://graphql.org/learn/introspection/) that publishes the schema's structure. In fact, the introspection system can be queried using GraphQL8, for example:

```graphql
{
  __schema {
    queryType {
      name
    }
  }
}
# Returns:
# {
#   "data": {
#     "__schema": {
#       "queryType": {
#         "name": "Query"
#       }
#     }
#   }
# }
```

This system is used for GraphQL8 tooling like the [GraphiQL editor](https://github.com/graphql8/graphiql).

Here are the default parts of the introspection system:

- `__schema` is a root-level field that contains data about the schema: its entry points, types, and directives.
- `__type(name: String!)` is a root-level field that returns data about a type with the given `name`, if there is a type with that name.
- `__typename` works a bit differently: it can be added to _any_ selection, and it will return the type of object being queried.

Here are some `__typename` examples:

```graphql
{
  user(id: "1") {
    handle
    __typename
  }
}
# Returns:
# {
#   "data": {
#     "user": {
#       "handle": "rmosolgo",
#       "__typename": "User"
#     }
#   }
# }
```

For unions and interfaces, `__typename` returns the _object_ type for the current object, for example:

```graphql
{
  search(term: "puppies") {
    title
    __typename
  }
}
# Returns:
# {
#   "data": {
#     "search": [
#       {
#         "title": "Sound of Dogs Barking",
#         "__typename": "AudioClip",
#       },
#       {
#         "title": "Cute puppies playing with a stick",
#         "__typename": "VideoClip",
#       },
#       {
#         "title": "The names of my favorite pets",
#         "__typename": "TextSnippet"
#       },
#     ]
#   }
# }
```

## Customizing Introspection

This is an __experimental feature__, only supported in class-based schemas.

With a class-based schema, you can use custom introspection types.

```ruby
# create a module namespace for your custom types:
module Introspection
  # described below ...
end

class MySchema < GraphQL8::Schema
  # ...
  # then pass the module as `introspection`
  introspection Introspection
end
```

Keep in mind that off-the-shelf tooling may not support your custom introspection fields. You may have to modify existing tooling or create your own tools to make use of your extensions.

### Introspection Namespace

The introspection namespace may contain a few different customizations:

- Class-based {% internal_link "object definitions", "/type_definitions/objects" %} which replace the built-in introspection types (such as `__Schema` and `__Type`)
- `EntryPoints`, A class-based {% internal_link "object definition", "/type_definitions/objects" %} containing introspection entry points (like `__schema` and `__type(name:)`).
- `DynamicFields`, A class-based {% internal_link "object definition", "/type_definitions/objects" %} containing dynamic, globally-available fields (like `__typename`.)

### Custom Introspection Types

The `module` passed as `introspection` may contain classes with the following names, which replace the built-in introspection types:

Custom class name | GraphQL8 type | Built-in class name
--|--|--
`SchemaType` | `__Schema` | {{ "GraphQL8::Introspection::SchemaType" | api_doc }}
`TypeType` | `__Type` | {{ "GraphQL8::Introspection::TypeType" | api_doc }}
`DirectiveType` | `__Directive` | {{ "GraphQL8::Introspection::DirectiveType" | api_doc }}
`DirectiveLocationType` | `__DirectiveLocation` | {{ "GraphQL8::Introspection::DirectiveLocationEnum" | api_doc }}
`EnumValueType` | `__EnumValue` | {{ "GraphQL8::Introspection::EnumValueType" | api_doc }}
`FieldType` | `__Field` | {{ "GraphQL8::Introspection::FieldType" | api_doc }}
`InputValueType` | `__InputValue` | {{ "GraphQL8::Introspection::InputValueType" | api_doc }}
`TypeKindType` | `__TypeKind` | {{ "GraphQL8::Introspection::TypeKindEnum" | api_doc }}

The class-based definitions' names _must_ match the names of the types they replace.

#### Extending a Built-in Type

The built-in classes listed above may be extended:

```ruby
module Introspection
  class SchemaType < GraphQL8::Introspection::SchemaType
    # ...
  end
end
```

Inside the class definition, you may:

- add new fields by calling `field(...)` and providing implementations
- redefine field structure by calling `field(...)`
- provide new field implementations by defining methods
- provide new descriptions by calling `description(...)`

### Introspection Entry Points

The GraphQL8 spec describes two entry points to the introspection system:

- `__schema` returns data about the schema (as type `__Schema`)
- `__type(name:)` returns data about a type, if one is found by name (as type `__Type`)

You can re-implement these fields or create new ones by creating a custom `EntryPoints` class in your introspection namespace:

```ruby
module Introspection
  class EntryPoints < GraphQL8::Introspection::EntryPoints
    # ...
  end
end
```

This class an object type definition, so you can override fields or add new ones here. They'll be available on the root `query` object, but ignored in introspection (just like `__schema` and `__type`).

### Dynamic Fields

The GraphQL8 spec describes a field which may be added to _any_ selection: `__typename`. It returns the name of the current GraphQL8 type.

You can add fields like this (or override `__typename`) by creating a custom `DynamicFields` defintion:

```ruby
module Introspection
  class DynamicFields < GraphQL8::Introspection::DynamicFields
    # ...
  end
end
```

Any fields defined there will be available in any selection, but ignored in introspection (just like `__typename`).

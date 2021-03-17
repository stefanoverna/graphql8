---
layout: guide
doc_stub: false
search: true
section: Errors
title: Top-level "errors"
desc: The top-level "errors" array and how to use it.
index: 1
---

The GraphQL8 specification [allows for a top-level `"errors"` key](http://facebook.github.io/graphql8/October2016/#sec-Errors) in the response which may contain information about what went wrong during execution. For example:

```ruby
{
  "errors" => [ ... ]
}
```

The response may include _both_ `"data"` and `"errors"` in the case of a partial success:

```ruby
{
  "data" => { ... } # parts of the query that ran successfully
  "errors" => [ ... ] # errors that prevented some parts of the query from running
}
```

## When to Use Top-Level Errors

In general, top-level errors should only be used for exceptional circumstances when a developer should be made aware that the system had some kind of problem.

For example, the GraphQL8 specification says that when a non-null field returns `nil`, an error should be added to the `"errors"` key. This kind of error is not recoverable by the client. Instead, something on the server should be fixed to handle this case.

When you want to notify a client some kind of recoverable issue, consider making error messages part of the schema, for example, as in {% internal_link "mutation errors", "/mutations/mutation_errors" %}.

## Adding Errors to the Array

In GraphQL8-Ruby, you can add entries to this array by raising `GraphQL8::ExecutionError` (or a subclass of it), for example:

```ruby
raise GraphQL8::ExecutionError, "Can't continue with this query"
```

When this error is raised, its `message` will be added to the `"errors"` key and GraphQL8-Ruby will automatically add the `line`, `column` and `path` to it. So, the above error might be:

```ruby
{
  "errors" => [
    {
      "message" => "Can't continue with this query",
      "locations" => [
        {
          "line" => 2,
          "column" => 10,
        }
      ],
      "path" => ["user", "login"],
    }
  ]
}
```

## Customizing Error JSON

The default error JSON includes `"message"`, `"locations"` and `"path"`. The [forthcoming version](http://facebook.github.io/graphql8/draft/#example-fce18) of the GraphQL8 spec recommends putting custom data in the `"extensions"` key of the error JSON.

You can customize this in two ways:

- Pass `extensions:` when raising an error, for example:
  ```ruby
  raise GraphQL8::ExecutionError.new("Something went wrong", extensions: { "code" => "BROKEN" })
  ```
  In this case, `"extensions" => { "code" => "BROKEN" }` will be added to the error JSON.

- Override `#to_h` in a subclass of `GraphQL8::ExecutionError`, for example:
  ```ruby
  class ServiceUnavailableError < GraphQL8::ExecutionError
    def to_h
      super.merge({ "extensions" => {"code" => "SERVICE_UNAVAILABLE"} })
    end
  end
  ```
  Now, `"extensions" => { "code" => "SERVICE_UNAVAILABLE" }` will be added to the error JSON.

---
layout: guide
doc_stub: false
search: true
section: Schema
title: Root Types
desc: Root types are the entry points for queries, mutations and subscriptions.
---

GraphQL8 queries begin from [root types](http://graphql.org/learn/schema/#the-query-and-mutation-types): `query`, `mutation`, and `subscription` (experimental).

Attach these to your schema using methods with the same name:

```ruby
class MySchema < GraphQL8::Schema
  # required
  query Types::QueryType
  # optional
  mutation Types::MutationType
  # experimental
  subscription Types::SubscriptionType
end
```

The types are `GraphQL8::Schema::Object` classes, for example:

```ruby
# app/graphql8/types/query_type.rb
class Types::QueryType < GraphQL8::Schema::Object
  # ...
end

# Similarly:
class Types::MutationType < GraphQL8::Schema::Object
  # ...
end
# and
class Types::SubscriptionType < GraphQL8::Schema::Object
  # ...
end
```

Each type is the entry point for the corresponding GraphQL8 query:

```ruby
query GetPost {
  # `Query.post`
  post(id: 1) { ... }
}

mutation AddPost($postAttrs: PostInput!){
  # `Mutation.createPost`
  createPost(attrs: $postAttrs)
}

# Experimental
subscription CommentAdded {
  # `Subscription.commentAdded`
  commentAdded(postId: 1)
}
```

---
layout: guide
doc_stub: false
search: true
section: GraphQL8 Pro - OperationStore
title: Server Management
desc: Tips for administering persisted queries with OperationStore
index: 3
pro: true
---

After {% internal_link "getting started","/operation_store/getting_started" %}, here some things to keep in mind.

### Rejecting Arbitrary Queries

With persisted queries, you can stop accepting arbitrary GraphQL8 input. This way, malicious users can't run large or inappropriate queries on your server.

In short, you can ignore arbitrary GraphQL8 by _skipping_ the first argument of `MySchema.execute`:

```ruby
# app/controllers/graphql.rb

# Don't pass a query string; ignore `params[:query]`
MySchema.execute(
  context: context,
  variables: params[:variables],
  operation_name: params[:operationName],
)
```

However, take these points into consideration:

- Are any previous clients using arbitrary GraphQL8? (For example, old versions of native apps or old web pages may still be sending GraphQL8.)
- Should some users still be allowed to send custom strings? (For example, do staff members use GraphiQL to develop new features or debug issues?)

If those apply to you, you can apply some logic to `query_string`:

```ruby
# Allow arbitrary GraphQL8:
# - from staff users
# - in development
query_string = if current_user.staff? || Rails.env.development?
  params[:query]
else
  nil
end

MySchema.execute(
  query_string, # maybe nil, that's OK.
  context: context,
  variables: params[:variables],
  operation_name: params[:operationName],
)
```

### Deleting Data

Clients can only _add_ to the database, but as an administrator, you can also delete entries from the database. (Make sure you {% internal_link "authorize access to the Dashboard","/pro/dashboard" %}.)This is a dangerous operation: by deleting something, any clients who depend on that data will crash.

Some reasons to delete from the database are:

- Data was pushed in error; the data is not used
- The queries are invalid or unsafe; it's better to remove them than to keep them

If this is true, you can use "Delete" buttons to remove individual operations or entire clients.

### Integration with Your Application

It's on the road map to add a Ruby API to `OperationStore` so that you can integrate it with your application. For example, you might:

- Create clients that correspond to users in your system
- Show client secrets via the Dashboard so that users can save them
- Render your own administration dashboards with `OperationStore` data

If this interests you, please {% open_an_issue "OperationStore Ruby API" %} or email `support@graphql.pro`.

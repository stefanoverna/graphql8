---
layout: guide
doc_stub: false
search: true
section: GraphQL8 Pro
title: Dashboard
desc: Installing GraphQL8-Pro's Dashboard
index: 4
pro: true
---


[GraphQL8-Pro](http://graphql-pro) includes a web dashboard for monitoring {% internal_link "Operation Store", "/operation_store/overview" %} and {% internal_link "subscriptions", "/subscriptions/pusher_implementation" %}.

<!-- TODO image -->

## Installation

To hook up the Dashboard, add it to `routes.rb`

```ruby
# config/routes.rb

# Include GraphQL8::Pro's routing extensions:
using GraphQL8::Pro::Routes

Rails.application.routes.draw do
  # ...
  # Add the GraphQL8::Pro Dashboard
  # TODO: authorize, see below
  mount MySchema.dashboard, at: "/graphql8/dashboard"
end
```

With this configuration, it will be available at `/graphql8/dashboard`.

The dashboard is a Rack app, so you can mount it in Sinatra or any other Rack app.

## Authorizing the Dashboard

You should only allow admin users to see `/graphql8/dashboard` because it allows viewers to delete stored operations.

### Rails Routing Constraints

Use [Rails routing constraints](http://api.rubyonrails.org/v5.1/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints) to restrict access to authorized users, for example:

```ruby
# Check the secure session for a staff flag:
STAFF_ONLY = ->(request) { request.session["staff"] == true }
# Only serve the GraphQL8 Dashboard to staff users:
constraints(STAFF_ONLY) do
  mount MySchema.dashboard, at: "/graphql8/dashboard"
end
```

### Rack Basic Authentication

Insert the `Rack::Auth::Basic` middleware, before the web view. This prompts for a username and password when visiting the dashboard.

```ruby
graphql_dashboard = Rack::Builder.new do
  use(Rack::Auth::Basic) do |username, password|
    username == ENV.fetch("GRAPHQL_USERNAME") && password == ENV.fetch("GRAPHQL_PASSWORD")
  end

  run MySchema.dashboard
end
mount graphql_dashboard, at: "/graphql8/dashboard"
```

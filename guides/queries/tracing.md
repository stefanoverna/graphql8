---
title: Tracing
layout: guide
doc_stub: false
search: true
section: Queries
desc: Observation hooks for execution
index: 11
experimental: true
---

{{ "GraphQL8::Tracing" | api_doc }} provides a `.trace` hook to observe events from the GraphQL8 runtime.

A tracer must implement `.trace`, for example:

```ruby
class MyCustomTracer
  def self.trace(key, data)
    # do stuff with key & data
    yield
  end
end
```

`.trace` is called with:

- `key`: the event happening in the runtime
- `data`: a hash of metadata about the event
- `&block`: the event itself, it must be `yield`ed and the value must be returned

To run a tracer for __every query__, add it to the schema with `tracer`:

```ruby
# Run `MyCustomTracer` for all queries
class MySchema < GraphQL8::Schema
  tracer(MyCustomTracer)
end
```

Or, to run a tracer for __one query only__, add it to `context:` as `tracers: [...]`, for example:

```ruby
# Run `MyCustomTracer` for this query
MySchema.execute(..., context: { tracers: [MyCustomTracer]})
```

For a full list of events, see the {{ "GraphQL8::Tracing" | api_doc }} API docs.

## ActiveSupport::Notifications

You can emit events to `ActiveSupport::Notifications` with an experimental tracer, `ActiveSupportNotificationsTracing`.

To enable it, install the tracer:

```ruby
# Send execution events to ActiveSupport::Notifications
class MySchema < GraphQL8::Schema
  tracer(GraphQL8::Tracing::ActiveSupportNotificationsTracing)
end
```

## Monitoring

Several monitoring platforms are supported out-of-the box by GraphQL8-Ruby (see platforms below).

Leaf fields are _not_ monitored (to avoid high cardinality in the metrics service).

Implementations are based on {{ "Tracing::PlatformTracing" | api_doc }}.

## Appsignal

To add [AppSignal](https://appsignal.com/) instrumentation:

```ruby
class MySchema < GraphQL8::Schema
  use(GraphQL8::Tracing::AppsignalTracing)
end
```

<div class="monitoring-img-group">
  {{ "/queries/appsignal_example.png" | link_to_img:"appsignal monitoring" }}
</div>

## New Relic

To add [New Relic](https://newrelic.com/) instrumentation:

```ruby
class MySchema < GraphQL8::Schema
  use(GraphQL8::Tracing::NewRelicTracing)
  # Optional, use the operation name to set the new relic transaction name:
  # use(GraphQL8::Tracing::NewRelicTracing, set_transaction_name: true)
end
```


<div class="monitoring-img-group">
  {{ "/queries/new_relic_example.png" | link_to_img:"new relic monitoring" }}
</div>

## Scout

To add [Scout APM](https://scoutapp.com/) instrumentation:

```ruby
class MySchema < GraphQL8::Schema
  use(GraphQL8::Tracing::ScoutTracing)
end
```

<div class="monitoring-img-group">
  {{ "/queries/scout_example.png" | link_to_img:"scout monitoring" }}
</div>

## Skylight

To add [Skylight](http://skylight.io) instrumentation:

```ruby
class MySchema < GraphQL8::Schema
  use(GraphQL8::Tracing::SkylightTracing)
end
```


<div class="monitoring-img-group">
  {{ "/queries/skylight_example.png" | link_to_img:"skylight monitoring" }}
</div>

## Datadog

To add [Datadog](https://www.datadoghq.com) instrumentation:

```ruby
class MySchema < GraphQL8::Schema
  use(GraphQL8::Tracing::DataDogTracing)
end
```

## Prometheus

To add [Prometheus](https://prometheus.io) instrumentation:

```ruby
require 'prometheus_exporter/client'

class MySchema < GraphQL8::Schema
  use(GraphQL8::Tracing::PrometheusTracing)
end
```

The PrometheusExporter server must be run with a custom type collector that extends
`GraphQL8::Tracing::PrometheusTracing::GraphQL8Collector`:

```ruby
# lib/graphql_collector.rb

require 'graphql8/tracing'

class GraphQL8Collector < GraphQL8::Tracing::PrometheusTracing::GraphQL8Collector
end
```

```sh
bundle exec prometheus_exporter -a lib/graphql_collector.rb
```

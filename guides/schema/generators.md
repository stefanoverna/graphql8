---
layout: guide
doc_stub: false
search: true
title: Generators
section: Schema
desc: Use Rails generators to install GraphQL8 and scaffold new types.
index: 3
---

If you're using GraphQL8 with Ruby on Rails, you can use generators to:

- [setup GraphQL8](#graphqlinstall), including [GraphiQL](https://github.com/graphql8/graphiql), [GraphQL8::Batch](https://github.com/Shopify/graphql-batch), and [Relay](https://facebook.github.io/relay/)
- [scaffold types](#scaffolding-types)
- [scaffold Relay mutations](#scaffolding-mutations)
- [scaffold GraphQL8::Batch loaders](#scaffolding-loaders)

## graphql8:install

You can add GraphQL8 to a Rails app with `graphql8:install`:

```
rails generate graphql8:install
```

This will:

- Set up a folder structure in `app/graphql8/`
- Add schema definition
- Add base type classes
- Add a `Query` type definition
- Add a route and controller for executing queries
- Install [`graphiql-rails`](https://github.com/rmosolgo/graphiql-rails)

After installing you can see your new schema by:

- `bundle install`
- `rails server`
- Open `localhost:3000/graphiql`

### Options

- `--relay` will add [Relay](https://facebook.github.io/relay/)-specific code to your schema
- `--batch` will add [GraphQL8::Batch](https://github.com/Shopify/graphql-batch) to your gemfile and include the setup in your schema
- `--no-graphiql` will exclude `graphiql-rails` from the setup
- `--schema=MySchemaName` will be used for naming the schema (default is `#{app_name}Schema`)

## Scaffolding Types

Several generators will add GraphQL8 types to your project. Run them with `-h` to see the options:

- `rails g graphql8:object`
- `rails g graphql8:interface`
- `rails g graphql8:union`
- `rails g graphql8:enum`
- `rails g graphql8:scalar`


## Scaffolding Mutations

You can prepare a Relay Classic mutation with

```
rails g graphql8:mutation #{mutation_name}
```

## Scaffolding Loaders

You can prepare a GraphQL8::Batch loader with

```
rails g graphql8:loader
```

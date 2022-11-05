---
layout: post
title:  "Ash Framework 2.1 Tutorial - 06 GraphQL"
date:   2022-11-04 01:59:53 +0200
updated:   2022-11-05 01:59:53 +0200
slug: elixir
publish: true
categories: elixir phoenix ash
excerpt: Adding a GraphQL API to Ash
---
Update the Support API file to:

### Configure

update the mix file with:
```elixir
# mix.exs
  defp deps do
    [
      {:ash, "~> 2.1"},
      {:ash_phoenix, "~> 1.1"},
      {:ash_postgres, "~> 1.0"},
      {:ash_graphql, "~> 0.21.0"},
      {:absinthe_plug, "~> 1.5.8"},
```

Update the Support API definition to include json
```elixir
# lib/helpdesk/support.ex
defmodule Helpdesk.Support do
  use Ash.Api, extensions: [
    AshGraphql.Api
  ]

  graphql do
    authorize? false # Defaults to `true`, just for testing
  end

  resources do
    # This defines the set of resources that can be used with this API
    registry Helpdesk.Support.Registry
  end
end
```

## Update Resource

```elixir
# lib/helpdesk/support/resources/ticket.ex
defmodule Ticket do
  use Ash.Resource,
    extensions: [
      AshGraphql.Resource
    ]

  graphql do
    type :ticket

    queries do
      get :get_ticket, :read # <- create a field called `get_post` that uses the `read` read action to fetch a single post
      # read_one :current_user, :current_user # <- create a field called `current_user` that uses the `current_user` read action to fetch a single record
      list :list_tickets, :read # <- create a field called `list_posts` that uses the `read` read action to fetch a list of posts
    end

    mutations do
      # And so on
      create :create_ticket, :create
      update :assign_ticket, :update
      update :start_ticket, :update
      update :close_ticket, :update
      destroy :destroy_ticket, :destroy
    end
  end
end
```

## GraphQL Schema

```elixir
# lib/helpdesk/support/schema.ex
defmodule Helpdesk.Support.Schema do
  use Absinthe.Schema

  @apis [Helpdesk.Support]

  use AshGraphql, apis: @apis

  query do
  end

  def context(ctx) do
    AshGraphql.add_context(ctx, @apis)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end

```

## Resources

* https://github.com/ash-project/ash_graphql
* https://hexdocs.pm/ash_graphql/AshGraphql.html
* https://ash-hq.org/docs/guides/ash_graphql/0.21.0/tutorials/getting-started-with-graphql

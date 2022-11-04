---
layout: post
title:  "Phoenix 1.7 with Ash 2.1 - 04 PostgreSQL"
date:   2022-06-11 01:59:53 +0200
updated:   2022-08-01 01:59:53 +0200
slug: elixir
publish: true
categories: elixir phoenix ash
excerpt: Integrating PostgreSQL into the Ash Framework
---

I've been curious about the Elixir Ash Framework and had some time.  It looks like it helps create an application framework and has many pre-built common solutions.  Authorization, Queries, Application Structure, etc.

As usual, I struggle with API documentation, and I love tutorials.  So I followed the instructions at:
https://www.ash-hq.org/docs/guides/ash/2.4.1/tutorials/get-started.md#module-docs
and integrated it with the slightly outdated Ash 1.x [slide notes](https://speakerdeck.com/zachsdaniel1/introduction-to-the-ash-framework-elixir-conf-2020?slide=16) from a 2020 ElixirConf talk by Zach Daniel called
[Introduction to the Ash Framework](https://www.youtube.com/watch?v=2U3vQHXCF0s)

Here is what I had to do (learn and adjust) to get up and running.

----------
This article builds on

## Ash Postgres -- Configure

My goal here was to configure Ash so that a pre-existing Phoenix Ecto Repo would keep working and Ash would work along side it.

Here is what I did (a deeper dive into: https://github.com/ash-project/ash_postgres/blob/main/documentation/tutorials/get-started-with-postgres.md)

We will make a new Ash Repo:
```elixir
# lib/helpdesk/support/repo.ex
defmodule Support.Repo do
  use AshPostgres.Repo, otp_app: :helpdesk
end
```

Now tell Phoenix Config:
```elixir
# config/config.exs
import Config

# add Ash APIs to config
config :helpdesk,
  ash_apis: [Helpdesk.Support]

config :helpdesk,
  ecto_repos: [
    Support.Repo, # add newly created Support Repo
    Helpdesk.Repo
  ]
# ...
```

In the `config/dev.exs` config add the Support database config alongside the Phoenix Ecto config:
```elixir
# config/dev.exs
import Config

# Phoenix Dev DB config
config :helpdesk, Helpdesk.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "helpdesk_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Ash dev DB Config
config :helpdesk, Support.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "support_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
# ...
```

Update `config/test.exs` database settings with:
```elixir
# config/test.exs
import Config

# Configure your phoenix database
config :helpdesk, Helpdesk.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "helpdesk_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
# Configure your ash (support) database
config :helpdesk, Support.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "support_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10
# ...
```

Finally, update `config/runtime.exs` with (note I haven't deployed - so this is untested):
```elixir
# config/runtime.exs
import Config

if System.get_env("PHX_SERVER") do
  config :helpdesk, HelpdeskWeb.Endpoint, server: true
end

if config_env() == :prod do
  support_database_url =
    System.get_env("SUPPORT_DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """
  phoenix_database_url =
    System.get_env("PHOENIX_DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :helpdesk, Support.Repo,
    # ssl: true,
    url: support_database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  config :helpdesk, Helpdesk.Repo,
    # ssl: true,
    url: phoenix_database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6
# ...
```

Hopefully you can start `iex -S mix`

## Ash Postgres -- Enable

Now we need to tell our `resources` about our new `Support.Repo`, we will do this in the 'ticket' and 'user' files -- we will replace `use Ash.Resource, data_layer: Ash.DataLayer.Ets` with:

```elixir
# lib/helpdesk/support/resources/ticket.ex
defmodule Helpdesk.Support.Ticket do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tickets"
    repo Support.Repo
  end
# ...
```

and
```elixir
# lib/helpdesk/support/resources/user.ex

defmodule Helpdesk.Support.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "users"
    repo Support.Repo
  end
# ...
```

Now we should be able to create the 'Support' database with:
```bash
mix ash_postgres.create
```

If you get an --apis error then you probably forgot the API config in `config/config.exs` try adding:
```elixir
# config/config.exs
import Config

config :helpdesk,
  ash_apis: [Helpdesk.Support]

# ...
```

Assuming this worked now you can generate a migration from existing 'resources' with:
```elixir
mix ash_postgres.generate_migrations --name support_add_tickets_and_users
```

This should create a migration that looks like:
```elixir
# priv/repo/migrations/YYYYMMDDHHmmSS_support_add_tickets_and_users.exs
defmodule Support.Repo.Migrations.SupportAddTicketsAndUsers do
  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text
    end

    create table(:tickets, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :subject, :text, null: false
      add :status, :text, null: false, default: "open"
      add :reporter_id,
          references(:users,
            column: :id,
            name: "tickets_reporter_id_fkey",
            type: :uuid,
            prefix: "public"
          )
      add :representative_id,
          references(:users,
            column: :id,
            name: "tickets_representative_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:tickets, "tickets_representative_id_fkey")
    drop constraint(:tickets, "tickets_reporter_id_fkey")
    drop table(:tickets)
    drop table(:users)
  end
end
```

Finally we can update the database by migrating using:
```bash
mix ash_postgres.migrate
```

## Ash Postgres - Actions

Now all our previous actions and queries should still work, but now persist long-term (even if we kill our iex session).

Let's start a new `iex` session now that we have switched to PostgreSQL and try out our Actions like before.
```elixir
iex -S mix

for i <- 0..5 do
  ticket =
    Helpdesk.Support.Ticket
    |> Ash.Changeset.for_create(:new, %{subject: "Issue #{i}"})
    |> Helpdesk.Support.create!()

  if rem(i, 2) == 0 do
    ticket
    |> Ash.Changeset.for_update(:close)
    |> Helpdesk.Support.update!()
  end
end
```

Now kill `iex` and start it again and ensure the following Queries works (and find the data we stored earlier):
```elixir
iex -S mix

# use `read` to list all users
{:ok, users} = Helpdesk.Support.read(Helpdesk.Support.User)
{:ok, tickets}= Helpdesk.Support.read(Helpdesk.Support.Ticket)

# use 'get' to get one record when you know the id
ticket_last = List.last(tickets)
Helpdesk.Support.get(Helpdesk.Support.Ticket, ticket_last.id)

# use Queries for more complex (nuanced lookups)
require Ash.Query

# Show the tickets where the subject contains "2"
Helpdesk.Support.Ticket
|> Ash.Query.filter(contains(subject, "2"))
|> Helpdesk.Support.read!()

# Show the tickets that are closed and their subject does not contain "4"
Helpdesk.Support.Ticket
|> Ash.Query.filter(status == :closed and not(contains(subject, "4")))
|> Helpdesk.Support.read!()
```

## Aggregates

Aggregates are a tool to include grouped data regarding **relationships** https://hexdocs.pm/ash/Ash.Resource.Dsl.html#module-aggregates

Aggregates are powerful because they will be translated to SQL, and can be used in filters and sorts (they are a bit like rails `scopes`).

So to try this out lets add ticket aggregates to our users - so we know how many tickets each user has (per ticket status)

The first argument is the aggregate name and the second is the relationship to count (and of course we can filter the results for mor meaningful grouping)

Possible aggregrates include:
* count
* first
* sum
* list

Let's start with trying aggregates within queries:
```elixir
Helpdesk.Support.User
|> Ash.Query.aggregate(:all_reported_tickets, [:reported_tickets])
|> Helpdesk.Support.read!()

Helpdesk.Support.User
|> Ash.Query.aggregate(:all_reported_tickets, [:reported_tickets],
                       filter: expr(status != :closed))
|> Helpdesk.Support.read!()
```

The possible filters available are found at: https://hexdocs.pm/ash/Ash.Filter.html

The basic aggregate format is `method :aggregate_name, :relationship_name`

Let's create some ticket aggregates for our users:
```elixir
# lib/helpdesk/support/resources/user.ex
  aggregates do
    count :all_reported_tickets, :reported_tickets
    count :open_reported_tickets, :reported_tickets do
      filter expr(status == :open || status == :new)
    end
    count :closed_reported_tickets, :reported_tickets do
      filter expr(status == :closed)
    end

    count :active_assigned_tickets, :assigned_tickets do
      filter expr(status == :open || status == :new)
    end
    count :closed_assigned_tickets, :assigned_tickets do
      filter expr(status == :closed)
    end
  end

  relationships do
    has_many :assigned_tickets, Helpdesk.Support.Ticket do
      destination_attribute :representative_id
    end
    has_many :reported_tickets, Helpdesk.Support.Ticket do
      destination_attribute :reporter_id
    end
  end
```

To use aggregates, we can access the aggregates them within our queries (filters and sorts).  Here is an example using the closed tickets within a query:
```elixir
iex -S mix

require Ash.Query

users = Helpdesk.Support.User
|> Ash.Query.filter(closed_assigned_tickets < 4) # users with less than 4 closed assigned tickets
|> Ash.Query.sort(closed_assigned_tickets: :desc)
|> Helpdesk.Support.read!()
# we get (as you see only the requested aggregate will be queried / calculated):
[
  #Helpdesk.Support.User<
    closed_assigned_tickets: 1,
    active_assigned_tickets: #Ash.NotLoaded<:aggregate>,
    closed_reported_tickets: #Ash.NotLoaded<:aggregate>,
    open_reported_tickets: #Ash.NotLoaded<:aggregate>,
    all_reported_tickets: #Ash.NotLoaded<:aggregate>,
    reported_tickets: #Ash.NotLoaded<:relationship>,
    assigned_tickets: #Ash.NotLoaded<:relationship>,
    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
    id: "1b00d77c-bff4-4f3b-8453-67f7c3748a59",
    name: "Jose",
    aggregates: %{},
    calculations: %{},
    __order__: nil,
    ...
  >,
  #Helpdesk.Support.User<
    closed_assigned_tickets: 0,
    active_assigned_tickets: #Ash.NotLoaded<:aggregate>,
    closed_reported_tickets: #Ash.NotLoaded<:aggregate>,
    open_reported_tickets: #Ash.NotLoaded<:aggregate>,
    all_reported_tickets: #Ash.NotLoaded<:aggregate>,
    reported_tickets: #Ash.NotLoaded<:relationship>,
    assigned_tickets: #Ash.NotLoaded<:relationship>,
    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
    id: "0c18bf1d-44bb-4499-b08b-48abf6fd27f4",
    name: "Nyima",
    aggregates: %{},
    calculations: %{},
    __order__: nil,
    ...
  >,
]

# even though aggregates are not automatically loaded unless requested
users = Helpdesk.Support.read!(Helpdesk.Support.User)
  Helpdesk.Support.User<
    closed_assigned_tickets: #Ash.NotLoaded<:aggregate>,
    active_assigned_tickets: #Ash.NotLoaded<:aggregate>,
    closed_reported_tickets: #Ash.NotLoaded<:aggregate>,
    open_reported_tickets: #Ash.NotLoaded<:aggregate>,
    all_reported_tickets: #Ash.NotLoaded<:aggregate>,
    reported_tickets: #Ash.NotLoaded<:relationship>,
    assigned_tickets: #Ash.NotLoaded<:relationship>,
    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
    id: "1b00d77c-bff4-4f3b-8453-67f7c3748a59",
    name: "Jose",
    aggregates: %{},
    calculations: %{},
    __order__: nil,

# we load aggregates as needed after the initial query
Helpdesk.Support.load!(users, :active_assigned_tickets)

# we can load multiple calculation
users = Helpdesk.Support.read!(Helpdesk.Support.User)
Helpdesk.Support.load!(users, [:active_assigned_tickets, :closed_assigned_tickets])
```

## Calculations

We can do SQL calculations too:
```elixir

Helpdesk.Support.User
|> Ash.Query.calculate(:username, expr(name <> "-"))
|> Helpdesk.Support.read!()

# or mixed
Helpdesk.Support.User
|> Ash.Query.calculate(:username, expr(name <> "-"))
|> Ash.Query.aggregate(:all_reported_tickets, [:reported_tickets],
                       filter: expr(status != :closed))
|> Helpdesk.Support.read!()
```

Pre-built calculations:
```elixir
# lib/helpdesk/support/resources/user.ex
  calculations do
    # calculate :full_name, :string, expr(first_name <> " " <> last_name)
    calculate :username, :string, expr(name <> "-" <> id)
    calculate :assigned_open_percent, :float, expr(active_assigned_tickets / all_assigned_tickets )
  end
```

USAGE:
```elixir
iex -S mix

require Ash.Query

Helpdesk.Support.User
|> Ash.Query.filter(all_assigned_tickets > 0) # prevent divide by zero
|> Ash.Query.filter(assigned_open_percent > 0.25)
|> Ash.Query.sort(:assigned_open_percent)
|> Ash.Query.load(:assigned_open_percent)
|> Helpdesk.Support.read!()

# try out the username calculation
Helpdesk.Support.User
|> Ash.Query.load(:username)
|> Helpdesk.Support.read!()

# calculations can also be loaded in a separate query afterwards
users = Helpdesk.Support.read!(Helpdesk.Support.User)
Helpdesk.Support.load!(users, :username)

# we can load multiple calculations and aggregates
users = Helpdesk.Support.read!(Helpdesk.Support.User)
Helpdesk.Support.load!(users, [:username, :closed_assigned_tickets])
```

# Resources

* https://www.youtube.com/watch?v=2U3vQHXCF0s
* https://hexdocs.pm/ash/relationships.html#loading-related-data
* https://www.ash-hq.org/docs/guides/ash/2.4.1/tutorials/get-started.md
* https://github.com/ash-project/ash_postgres/blob/main/documentation/tutorials/get-started-with-postgres.md

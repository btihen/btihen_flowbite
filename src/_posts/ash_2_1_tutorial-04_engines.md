---
layout: post
title:  "Ash 2.1 Tutorial - 04 Engines"
date:   2022-11-04 01:59:53 +0200
updated:   2022-11-05 01:59:53 +0200
slug: elixir
publish: true
categories: elixir phoenix ash
excerpt: Adding Relationships into Ash Resources
---

In order to build relationships we will need more than one resource.  So lets quickly build the 'ticket' resource - also using ETS as the data layer (for now).  I won't explain the `actions` and `attributes` since that has already been covered in the [intro article](/elixir/phoenix_1_7_ash_2_1_02_relationships/).
```elixir
# lib/support/resources/ticket.ex
defmodule Support.Ticket do
  # This turns this module into a resource
  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :status, :atom do
      constraints [one_of: [:new, :open, :closed]]
      default :new
      allow_nil? false
    end

    attribute :priority, :atom do
      constraints [one_of: [:low, :medium, :high]]
      default :low
      allow_nil? false
    end

    attribute :subject, :string do
      allow_nil? false
    end

    attribute :description, :string do
      allow_nil? false
    end
  end
end
```

Now we need to update the registry to include Ticket too:
```elixir
# lib/support/registry.ex
defmodule Support.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Support.Ticket
    entry Support.User
  end
end
```


## Ash Relationships

### Belongs to

The tickets will need a `relationship` section that points to the users - in this case we have two 'relationships':
* a reporter (customers or employees)
* a representative (only employees)
that both point back to the same user 'resource'.  We use `belong_to` meaning that the destination attribute is unique, meaning only one related record could exist.
```elixir
# lib/support/resources/ticket.ex
  # ...
  relationships do
    belongs_to :reporter, Support.User
    belongs_to :representative, Support.User
  end
  # ...
```

### Has many


```elixir
# lib/support/resources/user.ex
  # ...
  relationships do
    # in a simple relationship this works if the other side references user_id
    # has_many :tickets, Support.Ticket

    # with overloaded references we need to declare the remote key
    has_many :assigned_tickets, Support.Ticket do
      destination_attribute :representative_id
    end
    has_many :reported_tickets, Support.Ticket do
      destination_attribute :reporter_id
    end
  end
  # ...
```

### Testing

```elixir
iex -S mix phx.server

customer = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_customer, %{first_name: "Ratna", last_name: "Sönam", email: "nyima@example.com"}
    )
  |> Support.AshApi.create!()
)
employee = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_employee, %{first_name: "Nyima", last_name: "Sönam", email: "nyima@example.com",
                       department: "Office Actor", account_type: :employee}
    )
  |> Support.AshApi.create!()
)
admin = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_admin, %{first_name: "Karma", last_name: "Sönam", email: "karma@example.com",
                    department: "Office Admin", account_type: :employee, admin: true}
    )
  |> Support.AshApi.create!()
)


# Create new tickets
ticket1 = (
  Support.Ticket
  |> Ash.Changeset.for_create(
      :create, %{subject: "No Power", description: "nothing happens", reporter_id: customer.id}
    )
  |> Support.AshApi.create!()
)

ticket2 = (
  Support.Ticket
  |> Ash.Changeset.for_create(
      :create, %{subject: "Screen Broken", description: "it has crack", status: :open,
                 priority: :high, reporter_id: customer.id, representative_id: employee.id}
    )
  |> Support.AshApi.update!()
)
```

### Aggregates

Summarizing relationships


## many_to_many ?

### Custom Actions using Relationships

Now we need to create additional 'actions' for ticket to manage the relationships:
```elixir
# lib/support/resources/ticket.ex
  actions do
    # Add a set of simple actions. You'll customize these later.
    defaults [:create, :read, :update, :destroy]

    create :new do
      accept [:subject]

      argument :reporter_id, :uuid do
        allow_nil? false # This action requires reporter_id
      end

      change manage_relationship(:reporter_id, :reporter, type: :append_and_remove)
    end

    update :assign do
      # No attributes should be accepted
      accept []
      # We accept a representative's id as input here
      argument :representative_id, :uuid do
        # This action requires representative_id
        allow_nil? false
      end
      # We use a change here to replace the related representative
      change manage_relationship(:representative_id, :representative, type: :append_and_remove)
    end

    update :start do
      # No attributes should be accepted
      accept []
      # We accept a representative's id as input here
      argument :representative_id, :uuid do
        # This action requires representative_id
        allow_nil? false
      end
      # We use a change here to replace the related representative
      change manage_relationship(:representative_id, :representative, type: :append_and_remove)
      change set_attribute(:status, :open)
    end

    update :close do
      # We don't want to accept any input here
      accept []
      change set_attribute(:status, :closed)
    end
  # ...
```

We can learn more about managing ash relationships at: https://www.ash-hq.org/docs/module/ash/2.4.1/ash-resource-change-builtins#function-manage_relationship-3


Testing Relationships:
```elixir
iex -S mix
#
recompile()

# Create a reporter
reporter = (
  Support.User
  |> Ash.Changeset.for_create(:create, %{name: "Nyima Dog"})
  |> Support.create!()
)

# Open a ticket
ticket1 = (
  Support.Ticket
  |> Ash.Changeset.for_create(:new, %{subject: "I can't find my hand!", reporter_id: reporter.id})
  |> Support.create!()
)

# Create a representative
representative_joe = (
  Support.User
  |> Ash.Changeset.for_create(:create, %{name: "Joe"})
  |> Support.create!()
)

representative_jose = (
  Support.User
  |> Ash.Changeset.for_create(:create, %{name: "Jose"})
  |> Support.create!()
)

# Assign that representative
ticket2 = (
  ticket
  |> Ash.Changeset.for_update(:assign, %{representative_id: representative_joe.id})
  |> Support.update!()
)

# Start working on the Ticket
ticket = (
  ticket
  |> Ash.Changeset.for_update(:start, %{representative_id: representative_jose.id})
  |> Support.update!()
)

# close the ticket
ticket = (
  ticket
    |> Ash.Changeset.for_update(:close)
    |> Support.update!()
)
```









I've been curious about the Elixir Ash Framework and had some time.  It looks like it helps create an application framework and has many pre-built common solutions.  Authorization, Queries, Application Structure, etc.

As usual, I struggle with API documentation, and I love tutorials.  So I followed the instructions at:
https://www.ash-hq.org/docs/guides/ash/2.4.1/tutorials/get-started.md#module-docs
and integrated it with the slightly outdated Ash 1.x [slide notes](https://speakerdeck.com/zachsdaniel1/introduction-to-the-ash-framework-elixir-conf-2020?slide=16) from a 2020 ElixirConf talk by Zach Daniel called
[Introduction to the Ash Framework](https://www.youtube.com/watch?v=2U3vQHXCF0s)

Here is what I had to do (learn and adjust) to get up and running.

----------












## Install Phoenix (1.7)

First I wanted to try out the unreleased version of Phoenix - so I followed the pre-release notes at:
* https://github.com/phoenixframework/phoenix/blob/master/installer/README.md
* https://speakerdeck.com/zachsdaniel1/introduction-to-the-ash-framework-elixir-conf-2020?slide=6
```bash
mix archive.uninstall phx_new
git clone https://github.com/phoenixframework/phoenix
cd phoenix/installer
MIX_ENV=prod mix do archive.build, archive.install
cd ../..
mix phx.new helpdesk_phx
cd helpdesk_phx
mix ecto.create
git init
git add .
git commit -m "initial phoenix commit"
```

Now we have a fully functional Phoenix site (that does nothing)

----------

Now let's include the Ash Framework with the goal of leaving Phoenix fully functional and adding Ash.

## Add Ash (2.1)

Let's start by adding Ash to the mix file:
```elixir
# mix.exs
  defp deps do
    [
      {:ash, "~> 2.1"},
      {:ash_phoenix, "~> 1.1"},
      {:ash_postgres, "~> 1.0"},
      # this is a nice touch too if using vs-code and ElixirLs
      {:elixir_sense, github: "elixir-lsp/elixir_sense", only: [:dev, :test]},
      # ...
    ]
  end
```

and we can add these to our .formatter file too:
```elixir
# .formatter.exs
[
  import_deps: [:ecto, :ecto_sql, :phoenix, :ash, :ash_postgres, :ash_postgres],
  #                               add these ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  # ...
]
```

Now we need to install these dependencies (packages) with:
```bash
mix deps.get
```

----------

## Building with Ash

So let's build a `ticket support` system like they do in the tutorial.  We will need users and tickets.

As best as I understand as is organized in `applications` or `modules` in this case `support`

Within these `modules` we have `resources` (or models - in rails).

These `resources` will need to be `registered`.

The `support.ex` file is like an `applicaton.ex` file in normal elixir projects.

Lets start by building Tickets (and the necessary infrastructure `registry.ex` and `support.ex`):
```bash
mkdir -p lib/support/resources && touch $_/ticket.ex
touch lib/support/resources/user.ex
touch lib/support/registry.ex
touch lib/support.ex
```

### Resources (Ticket)

Resources are the core of an Ash Framework, they are like the `models` of rails - except they have MANY more facets: https://hexdocs.pm/ash/Ash.Resource.Dsl.html

* [actions](https://hexdocs.pm/ash/Ash.Resource.Dsl.html#module-actions)
* [attributes](https://hexdocs.pm/ash/Ash.Resource.Dsl.html#module-attributes)
* [identities](https://hexdocs.pm/ash/Ash.Resource.Dsl.html#module-identities)
* [validations](https://hexdocs.pm/ash/Ash.Resource.Dsl.html#module-validations)
* relationships
* aggregates
* calculations
* multitenancy
* changes
* code_interface
* resource
* preparations

For now we will only introduce a few features

We will start with the most basic possible setup (just tickets and no DB)
```elixir
# lib/support/resources/ticket.ex
defmodule Support.Ticket do
  # This turns this module into a resource
  use Ash.Resource

  actions do
    # basic actions - these are the building blocks for customized actions
    defaults [:create, :read, :update, :destroy]
  end

  # Attributes are the simple pieces of data that exist on your resource
  attributes do
    # Add an autogenerated UUID primary key called `:id`.
    uuid_primary_key :id
    attribute :subject, :string
  end
end
```

We define what can happen within `actions` - hopefully this is clear that enables us to create, read, update and destroy these resources:
```
  actions do
    defaults [:create, :read, :update, :destroy]
  end
```

We define what the `resource` has for attributes in the `attributes` section.  In Rails these are the model's attributes.

```elixir
# lib/support/resources/user.ex
defmodule Support.User do
  use Ash.Resource

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  # Attributes are the simple pieces of data that exist on your resource
  attributes do
    # Add an autogenerated UUID primary key called `:id`.
    uuid_primary_key :id

    attribute :first_name, :string do
      constraints min_length: 1
    end
    attribute :last_name, :string do
      constraints min_length: 1
    end
    attribute :admin, :boolean do
      allow_nil? false
      default false
    end
    attribute :representative, :boolean do
      allow_nil? false
      default false
    end
    attribute :email, :string do
      allow_nil? false
      constraints [
        match: ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$/
      ]
    end
    # attribute :type, :atom do
    #   constraints [
    #     one_of: [:admin, :teacher, :student]
    #   ]
    # end
    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  # provides a unique constraint - in order to uniquely identify the resource
  identities do
    identity :email, [:email]
    identity :full_name, [:first_name, :last_name]
  end

  # ensure that at least first or last name is given
  validations do
    validate present([:first_name, :last_name], at_least: 1)
  end

end
```

### Unique Identity

  identities do
    identity :full_name, [:first_name, :last_name]
    identity :email, [:email]
  end

## Ash Registry

I assume this keeps track of the resources we will be using.

```elixir
# lib/support/registry.ex
defmodule Support.Registry do
  use Ash.Registry,
    extensions: [
      # This extension adds helpful compile time validations
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Support.Ticket
  end
end
```

You can see this will allow us to add validations to our resources (later) in this case we have only registered `ticket` under the `entries`.

### Application API file

This file defines the set of resources that can be used with this API (or more accurately, says where to find the resources to load).  This file is named after the name of the module - in this case `support.ex` (but I wonder why its not called `support_api.ex`).

```elixir
# lib/support.ex
defmodule Support do
  use Ash.Api

  resources do
    # This defines the set of resources that can be used with this API
    registry Support.Registry
  end
end
```
----------

### Testing Ash (Tickets)

Let's see if what we built actually works.

We will create a 'ticket' resource and then query for it.

To do this we will need to:
1. build a change-set for the create action (for the Ticket resource)
2. give it the `create!` instruction

To do this we will test within iex:

```elixir
iex -S mix

Support.Ticket
|> Ash.Changeset.for_create(:create)
|> Support.create!()
```

Which hopefully returns something like:
```bash
#Support.Ticket<
  __meta__: #Ecto.Schema.Metadata<:built, "">,
  id: "bcc9729b-7fa2-4e7c-af45-3293be3394ee",
  subject: nil,
  aggregates: %{},
  calculations: %{},
  __order__: nil,
  ...
>
```

Notice that the subject is nil (we aren't yet using validations) and our primary key is a uuid.

### Attribute Constraints

Let's say we don't want to allow blank Subjects and we want to require a restricted list of statuses.

To prevent blanks in a field we can change the attribute subject to look like:
```elixir
# lib/support/resources/ticket.ex
# ...
  attributes do
    attribute :subject, :string do
      allow_nil? false
    end
    # ...
  end
# ...
```

Now lets add a set of restricted statuses (new, open, closed):
```elixir
# lib/support/resources/ticket.ex
# ...
  attributes do
    attribute :status, :atom do
       constraints [one_of: [:new, :open, :closed]]
       default :new
       allow_nil? false
     end
    # ...
  end
# ...
```

Now the `ticket` file should look like:
```elixir
# lib/support/resources/ticket.ex
defmodule Support.Ticket do
  # This turns this module into a resource
  use Ash.Resource

  actions do
    # A set of simple actions.
    defaults [:create, :read, :update, :destroy]
  end

  # Attributes are the simple pieces of data that exist on your resource
  attributes do
    # Add an autogenerated UUID primary key called `:id`.
    uuid_primary_key :id

    # Add a string type attribute called `:subject`
    attribute :subject, :string do
      allow_nil? false # Don't allow `nil` values
    end

    # status is either `open` or `closed`. We can add more statuses later
    attribute :status, :atom do
      # restricted list of statuses
      constraints [one_of: [:new, :open, :closed]]
      default :new # default value when none is given
      allow_nil? false # Don't allow `nil` values
    end
  end
end
```

### Custom Action

We want to create a custom `new` ticket action - that will only accept one attribute `subject` - which is also now required (per default all attributes will be accepted).

```elixir
# lib/support/resources/ticket.ex
# ...
  actions do
    # ...
    create :new do
      # By default all attributes are accepted by an action
      accept [:subject] # This action should only accept the subject
    end
    # ...
  end
# ...
```

We also want a `close` action:
```elixir
# lib/support/resources/ticket.ex
# ...
  actions do
    # ...
    update :close do
      accept [] # accept no input here
      change set_attribute(:status, :closed)
    end
    # ...
  end
# ...
```

Now the Ticket file should look like:
```elixir
# lib/support/resources/ticket.ex
defmodule Support.Ticket do
  # This turns this module into a resource
  use Ash.Resource

  actions do
    # Add a set of simple actions. You'll customize these later.
    defaults [:create, :read, :update, :destroy]

    create :new do
      accept [:subject] # only accept the subject - no other fields
    end

    update :close do
      accept [] # don't accept attributes
      change set_attribute(:status, :closed) # build the change set
    end
  end

    # Attributes are the simple pieces of data that exist on your resource
  attributes do
    # Add an autogenerated UUID primary key called `:id`.
    uuid_primary_key :id

    # Add a string type attribute called `:subject`
    attribute :subject, :string do
      allow_nil? false # Don't allow `nil` values
    end

    # status is either `open` or `closed`. We can add more statuses later
    attribute :status, :atom do
      # restricted list of statuses
      constraints [one_of: [:new, :open, :closed]]
      default :new # default value when none is given
      allow_nil? false # Don't allow `nil` values
    end
  end
end
```

To test this change we need to adjust our change set - if we don't we should get an error:
```elixir
iex -S mix
# just in case iex is already open
recompile()

Support.Ticket
|> Ash.Changeset.for_create(:new)
|> Support.create!()

# we should get the error:
** (Ash.Error.Invalid) Input Invalid
* attribute subject is required
# ...
```

To properly create a Ticket now -- the following should work:
```elixir
iex -S mix
# just in case iex is already open
recompile()

ticket = (
  Support.Ticket
  |> Ash.Changeset.for_create(:new, %{subject: "My mouse won't click!"})
  |> Support.create!()
)
```
we should get something like (notice we have a subject and it's status is `pending`):
```elixir
#Support.Ticket<
  __meta__: #Ecto.Schema.Metadata<:loaded, "tickets">,
  id: "b792b4f1-2167-4aa8-b654-4aef4938ba9a",
  subject: "My mouse won't click!",
  status: :new,
  # ...
```

Now let's test the `close` action on our new `ticket`:
```elixir
ticket
|> Ash.Changeset.for_update(:close)
|> Support.update!()
```

Now our ticket should look like:
```elixir
#Support.Ticket<
  __meta__: #Ecto.Schema.Metadata<:loaded, "tickets">,
  id: "ccd5af37-7cad-40c5-badd-71d5c67d50a5",
  subject: "My mouse won't click!",
  status: :closed,
  # ...
```

Since we have no storage at the moment we can't query our records.

Try:
```elixir
Support.AshApi.read!(Support.Ticket)
```

You should get an error - that says: 'there is no data to be read for that resource'

Let's enable queries - we need to configure a data layer for these resources

## Ash Data Layer

### Ash Queries - Simple Data Layer

We can add a default `Simple` data layer with the macro: `require Ash.Query`, so if we create some tickets using the script:

```elixir
# Ash.Query is a macro, so it must be required
require Ash.Query

tickets =
  for i <- 0..5 do
    ticket =
      Support.Ticket
      |> Ash.Changeset.for_create(:open, %{subject: "Issue #{i}"})
      |> Support.create!()

    if rem(i, 2) == 0 do
      ticket
      |> Ash.Changeset.for_update(:close)
      |> Support.update!()
    else
      ticket
    end
  end
```

Now we should be able to query and filter our tickets:
```elixir
# Show the tickets where the subject contains "2"
Support.Ticket
|> Ash.Query.filter(contains(subject, "2"))
|> Ash.DataLayer.Simple.set_data(tickets)
|> Support.AshApi.read!()

# Show the tickets that are closed and their subject does not contain "4"
Support.Ticket
|> Ash.Query.filter(status == :closed and not(contains(subject, "4")))
|> Ash.DataLayer.Simple.set_data(tickets)
|> Support.AshApi.read!()
```
Notice the power of the `filter` command, try adjusting.

To learn more visit:
* [Ash Queries](https://www.ash-hq.org/docs/module/ash/2.4.1/ash-query)
* [Writing an Ash Filter](https://www.ash-hq.org/docs/module/ash/2.4.1/ash-filter)


## Ash Persistence (ETS)

ETS is an in-memory (OTP based) way to persist data (we will work with PostgreSQL later).
Once we have persisted data we can explore relationships.

To add ETS to the Data Layer we need to change the line `use Ash.Resource` to:
```elixir
# lib/support/resources/ticket.ex
  # ...
  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets
  # ...
```
Now the file should look like:
```elixir
# lib/support/resources/ticket.ex
defmodule Support.Ticket do
  # This turns this module into a resource
  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets

  actions do
    # Add a set of simple actions. You'll customize these later.
    defaults [:create, :read, :update, :destroy]

    create :new do
      accept [:subject] # only accept the subject - no other fields
    end

    update :close do
      accept [] # don't accept attributes
      change set_attribute(:status, :closed) # build the change set
    end
  end

    # Attributes are the simple pieces of data that exist on your resource
  attributes do
    # Add an autogenerated UUID primary key called `:id`.
    uuid_primary_key :id

    # Add a string type attribute called `:subject`
    attribute :subject, :string do
      allow_nil? false # Don't allow `nil` values
    end

    # status is either `open` or `closed`. We can add more statuses later
    attribute :status, :atom do
      # restricted list of statuses
      constraints [one_of: [:new, :open, :closed]]
      default :new # default value when none is given
      allow_nil? false # Don't allow `nil` values
    end
  end
end
```

### Ash Queries - Persistent Data Layer

```elixir
iex -S mix
# and or
recompile()

# Actions (create & persist our records)
for i <- 0..5 do
  ticket =
    Support.Ticket
    |> Ash.Changeset.for_create(:new, %{subject: "Issue #{i}"})
    |> Support.create!()

  if rem(i, 2) == 0 do
    ticket
    |> Ash.Changeset.for_update(:close)
    |> Support.update!()
  end
end

# QUERY Data
# enable Ash Query (notice we no longer need to include the data layer in the query!)
require Ash.Query

# use `read` to list all users
{:ok, users} = Support.read(Support.User)
{:ok, tickets}= Support.read(Support.Ticket)

# use 'get' to get one record when you know the id
ticket_last = List.last(tickets)
Support.get(Support.Ticket, ticket_last.id)


# Show the tickets where the subject contains "2"
Support.Ticket
|> Ash.Query.filter(contains(subject, "2"))
|> Support.AshApi.read!()

# Show the tickets that are closed and their subject does not contain "4"
Support.Ticket
|> Ash.Query.filter(status == :closed and not(contains(subject, "4")))
|> Support.AshApi.read!()
```

## Ash Relationships

We will now create a `User` that can create or be assigned a ticket (using ETS as the data layer).

```elixir
# lib/support/resources/user.ex
defmodule Support.User do
  # This turns this module into a resource
  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
  end

  relationships do
    has_many :assigned_tickets, Support.Ticket do
      destination_attribute :representative_id
    end
    has_many :reported_tickets, Support.Ticket do
      destination_attribute :reporter_id
    end
  end
end
```
The `has_many` means that the destination attribute is not unique, meaning many related records could exist.


We also need to register our new `user` resource by adding:
```elixir
# lib/support/registry.ex
  entries do
    # ...
    entry Support.User
  end
```

So now our registry should look like:
```elixir
# lib/support/registry.ex
defmodule Support.Registry do
  use Ash.Registry,
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Support.Ticket
    entry Support.User
  end
end
```

Now we need to add the relationship to Tickets too:
```elixir
# lib/support/resources/ticket.ex
  # ...
  relationships do
    belongs_to :reporter, Support.User
    belongs_to :representative, Support.User
  end
  # ...
```
We use `belong_to` meaning that the destination attribute is unique, meaning only one related record could exist.

Now we need to create additional 'actions' for ticket to manage the relationships:
```elixir
# lib/support/resources/ticket.ex
  actions do
    # Add a set of simple actions. You'll customize these later.
    defaults [:create, :read, :update, :destroy]

    create :new do
      accept [:subject]

      argument :reporter_id, :uuid do
        allow_nil? false # This action requires reporter_id
      end

      change manage_relationship(:reporter_id, :reporter, type: :append_and_remove)
    end

    update :assign do
      # No attributes should be accepted
      accept []
      # We accept a representative's id as input here
      argument :representative_id, :uuid do
        # This action requires representative_id
        allow_nil? false
      end
      # We use a change here to replace the related representative
      change manage_relationship(:representative_id, :representative, type: :append_and_remove)
    end

    update :start do
      # No attributes should be accepted
      accept []
      # We accept a representative's id as input here
      argument :representative_id, :uuid do
        # This action requires representative_id
        allow_nil? false
      end
      # We use a change here to replace the related representative
      change manage_relationship(:representative_id, :representative, type: :append_and_remove)
      change set_attribute(:status, :open)
    end

    update :close do
      # We don't want to accept any input here
      accept []
      change set_attribute(:status, :closed)
    end
  # ...
```

We can learn more about managing ash relationships at: https://www.ash-hq.org/docs/module/ash/2.4.1/ash-resource-change-builtins#function-manage_relationship-3


Testing Relationships:
```elixir
iex -S mix
#
recompile()

# Create a reporter
reporter = (
  Support.User
  |> Ash.Changeset.for_create(:create, %{name: "Nyima Dog"})
  |> Support.create!()
)

# Open a ticket
ticket = (
  Support.Ticket
  |> Ash.Changeset.for_create(:new, %{subject: "I can't find my hand!", reporter_id: reporter.id})
  |> Support.create!()
)

# Create a representative
representative_joe = (
  Support.User
  |> Ash.Changeset.for_create(:create, %{name: "Joe"})
  |> Support.create!()
)

representative_jose = (
  Support.User
  |> Ash.Changeset.for_create(:create, %{name: "Jose"})
  |> Support.create!()
)

# Assign that representative
ticket = (
  ticket
  |> Ash.Changeset.for_update(:assign, %{representative_id: representative_joe.id})
  |> Support.update!()
)

# Start working on the Ticket
ticket = (
  ticket
  |> Ash.Changeset.for_update(:start, %{representative_id: representative_jose.id})
  |> Support.update!()
)

# close the ticket
ticket = (
  ticket
    |> Ash.Changeset.for_update(:close)
    |> Support.update!()
)
```

# Resources

* https://www.youtube.com/watch?v=2U3vQHXCF0s
* https://hexdocs.pm/ash/relationships.html#loading-related-data
* https://www.ash-hq.org/docs/guides/ash/2.4.1/tutorials/get-started.md

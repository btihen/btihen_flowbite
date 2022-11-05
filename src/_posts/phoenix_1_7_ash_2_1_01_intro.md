---
layout: post
title:  "Phoenix 1.7 with Ash 2.1 - 01 Introduction"
date:   2022-06-11 01:59:53 +0200
updated:   2022-08-01 01:59:53 +0200
slug: elixir
publish: true
categories: elixir phoenix ash
excerpt: Overview and getting started with the Ash Framework
---

I've been curious about the Elixir Ash Framework and with the current 'stable' release, I decided to spend part of my vacation to explore and hopefully learn Ash.

When learning, I enjoy tutorials that demonstrate:
* stepwise building an app (features within a context)
* demonstrate integrations that are similar to 'real-world' usages
I found this ElixirConf 2020 [Introduction to the Ash Framework](https://www.youtube.com/watch?v=2U3vQHXCF0s) video presentation by [Zach Daniel](https://github.com/zachdaniel) - the Ash Framework Author, which is what I was looking for, but its syntax and configuration is for Ash 1.x and not Ash 2.x.

I will try to reproduce the flow of the video tutorial for Ash 2.x (with a few side adventures of my own).  I am using the [Ash Tutorials / Hex Docs](https://hexdocs.pm/ash/get-started.html) and the associated [talk slides](https://speakerdeck.com/zachsdaniel1/introduction-to-the-ash-framework-elixir-conf-2020) the [Ash Docs](https://ash-hq.org/docs/guides/ash/latest) are also very helpful.

## Overview

[Ash Framework](https://ash-hq.org/) is a declarative, resource-oriented application development framework for [Elixir](https://elixir-lang.org/). A resource can model anything, like a database table, an external API, or even custom code.

Having played with Ash a bit now, it nicely separates the Data Layer and Business Logic, the Access APIs AND facilitates common needs / patterns, ie:
* Validations & Constraints
* Queries (aggregates, calculations)
* Authentication (not yet authorization)
* ...
Without excluding standard elixir tooling.  I haven't tried this, but Ash claims to be easily extensible.

Given the flexibility of Ash's uses of resources, we will start with a very simple organization (similar to rails - resources will reflect database tables that are directly acted upon.  Once the App gets a bit more complicated (and our resources get a annoyingly large), we will restructure the app to reflect a more modular approach.

NOTE: A resource based app that separates the Data Layer, Business Logic and Access Layers is a new fresh approach, but takes a bit of rethinking.

In the [Thinking Elixir Podcast # 123](https://podcast.thinkingelixir.com/123) Zach describes the design of Ash to be **Declarative Design** designed to preserve functional mindset and splits applications into two aspects.
1. **Resources** - a description of attributes and what actions are allowed (what is required and what should happen)
2. **Engine** - follow the instructions of the resource

In my mind, I currently think of Ash as having three Layers (I don't yet have a good feel for the Engines).
* External APIs - external access to data and actions (AshQuery, AshJsonAPI, AshGraphQL, AshPhoenix/LiveView)
* Resources - a description of what should happen (actions allowed and the data required)
* Data Layer - data persistence (in memory, ETS, Mnesia, PostgreSQL, etc)

## Project

Build and deploy a Simple Helpdesk Ticketing website.  This keeps this tutorial close to the Ash Documents and tutorials.  Thus we will install the Ash Framework within a Phoenix Project.

----------

## Install Phoenix (1.7)

First I let's install the unreleased version of Phoenix 1.7 by following these [instructions](https://github.com/phoenixframework/phoenix/blob/master/installer/README.md):
```bash
mix archive.uninstall phx_new
git clone https://github.com/phoenixframework/phoenix
cd phoenix/installer
MIX_ENV=prod mix do archive.build, archive.install
cd ../..
mix phx.new helpdesk
cd helpdesk
mix ecto.create
git init
git add .
git commit -m "initial phoenix commit"
iex -S mix phx.server
```

Now we have a fully functional Phoenix site - with the new Phoenix Tailwind CSS design.

![Phoenix 1.7 Start Page](/images/phoenix_ash_tutorial/phoenix_1_7.png)

## Add Ash (2.1)

Now let's include the Ash Framework within Phoenix -- with the goal of leaving Phoenix completely standard and parallel to Ash.


Start by adding Ash to the mix file:
```elixir
# mix.exs
  defp deps do
    [
      {:ash, "~> 2.1"},
      # {:ash_postgres, "~> 1.0"},
      # {:ash_graphql, "~> 0.21.0"},
      # {:ash_phoenix, "~> 1.1"},
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
  import_deps: [:ecto, :ecto_sql, :phoenix, :ash],
  #                                add this ^^^^
  # ...
]
```

Now we need to install these dependencies (packages) with:
```bash
mix deps.get
iex -S mix phx.server
```

----------

## Building with Ash

### Ash Structural Basics

Our system will need users, tickets and comments.

We will start with a user resource.

Ash needs to define its API and register its available resources - so we will create the following files:
```bash
mkdir -p lib/support/resources
touch lib/support/resources/user.ex
touch lib/support/registry.ex
touch lib/support/ash_api.ex
```

### User Resource

A resource minimally needs actions (things to do) and attributes (information associated with the resource)
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

    attribute :email, :string

    attribute :first_name, :string
    attribute :middle_name, :string
    attribute :last_name, :string

    attribute :admin, :boolean
    attribute :account_type, :atom # will limit to :employee, :customer
    attribute :department_name, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
```

The current `actions` (:create, :read, :update, :destroy) enable the basic CRUD operations used by the data layer.  We will expand and refine the actions soon.

The `attributes` are of course the associated information needed by the resource.  Notice there we are using several data types (:string, :boolean, :atom and :dates).  We will refine these attributes shortly and clearly define limits and contraints and validations on these data. See the [types](https://hexdocs.pm/ash/Ash.Type.html) docs for the full list available.

Since we are new to Ash, let's be sure we haven't made any mistakes, let's start phoenix and be sure there are no compile errors:
```elixir
iex -S mix phx.server
```

## Ash Registry

We need to register our resources with Ash (and any resource extensions - we will do this later). We can do this with a registry file:
```elixir
# lib/support/registry.ex
defmodule Support.Registry do
  use Ash.Registry

  entries do
    entry Support.User
  end
end
```

Notice that the resource is registered in the `entries`.

Again, let's test all is still well:
```elixir
iex -S mix phx.server
```

### Ash API

This file defines defines what APIs are associated with which resources.  We will build this out as we go too.
```elixir
# lib/support/ash_api.ex
defmodule Support.AshApi do
  use Ash.Api

  resources do
    registry Support.Registry
  end
end
```

Again, let's test all is still well:
```elixir
iex -S mix phx.server
```

### Usage

Let's see if what we built actually works.

Let's be sure we can create a 'user'.

To do this we will need to:
1. build a change-set for the create action (for the Ticket resource)
2. give it the `create!` instruction

To do this we will test within iex:

```elixir
iex -S mix phx.server

Support.User
|> Ash.Changeset.for_create()
|> Support.AshApi.create!()
```

So to explain this:
* we start with the desired resource
* we build a changeset `for_create` a new user (in this case we aren't providing any data, yet)
* finally, we invoke the `create` AshApi (within our Support app)

Which hopefully returns something like:
```elixir
#Support.User<
  __meta__: #Ecto.Schema.Metadata<:built, "">,
  id: "936ec1c0-cbde-4ba2-8726-e8288c081b1f",
  first_name: nil,
  middle_name: nil,
  last_name: nil,
  admin: nil,
  email: nil,
  department_name: nil,
  account_type: nil,
  inserted_at: ~U[2022-11-04 13:30:38.109136Z],
  updated_at: ~U[2022-11-04 13:30:38.109136Z],
  aggregates: %{},
  calculations: %{},
  __order__: nil,
  ...
>
```

This tests our `create` action, let's test our `attributes` too.

```elixir
iex -S mix phx.server

Support.User
|> Ash.Changeset.for_create(
    :create, %{first_name: "Nyima", last_name: "Sönam", admin: true, email: "nyima@example.com", account_type: :dog}
  )
|> Support.AshApi.create!()
```

Ideally, we now see that our attributes are filled with data we provided in the changeset.
```elixir
iex -S mix phx.server

#Support.User<
  __meta__: #Ecto.Schema.Metadata<:built, "">,
  id: "ac5b9358-a8f6-42ba-8922-36880b834004",
  first_name: "Nyima",
  middle_name: nil,
  last_name: "Sönam",
  admin: true,
  email: "nyima@example.com",
  department_name: nil,
  account_type: :dog,
  inserted_at: ~U[2022-11-04 13:39:06.531902Z],
  updated_at: ~U[2022-11-04 13:39:06.531902Z],
  aggregates: %{},
  calculations: %{},
  __order__: nil,
  ...
>
```

### Attribute Constraints

Of course we probably want some control of the attributes.  We want to ensure some fields receive data or limits on this data - for example, we want limit the account types to :employee or :customer, the admin field by default should be false, and we definately need a first and last name, but not a middle name.

So let's add some added info to our attributes:
* prevent nil attributes we use: `allow_nil? false`
* to ensure a default value we use: `default :value`
* to ensure a string is at least a few characters we use: `constraints min_length: integer`
* to ensure we restrict the allowed values we can use: `constraints [one_of: [:value1, :value2]]`

In our case, we can now update our user resource to:
```elixir
# lib/support/resources/user.ex
defmodule Support.User do
  use Ash.Resource

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  # Attributes are the simple pieces of data that exist on your resource
  attributes do
    uuid_primary_key :id

    attribute :email, :string do
      allow_nil? false
      constraints [
        match: ~r/^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$/
      ]
    end

    attribute :first_name, :string do
      constraints min_length: 1
      allow_nil? false
    end
    attribute :middle_name, :string do
      constraints min_length: 1
    end
    attribute :last_name, :string do
      constraints min_length: 1
      allow_nil? false
    end

    attribute :admin, :boolean do
      allow_nil? false
      default false
    end
    attribute :account_type, :atom do
      constraints [
        one_of: [:employee, :customer]
      ]
    end

    attribute :department_name, :string

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
```

Each `type` has its own `constraints`

[String Type](https://hexdocs.pm/ash/Ash.Type.String.html) for example I was delighted that by default leading and trailing spaces are trimmed with `trim?`

[Atom Type](https://hexdocs.pm/ash/Ash.Type.Atom.html) - conveniently, have allow a constrain to a list of atom using the: `:one_of` constraint.

**TESTEN**

```elixir
iex -S mix phx.server

Support.User
|> Ash.Changeset.for_create(
    :create, %{first_name: "Nyima", last_name: "Sönam", admin: true, email: "nyima@example.com", account_type: :dog}
  )
|> Support.AshApi.create!()
```

We should now get an error that :dog is not a valid account type, lets fix this:
```elixir
iex -S mix phx.server

Support.User
|> Ash.Changeset.for_create(
    :create, %{first_name: "Nyima", last_name: "Sönam", admin: true, email: "nyima@example.com", account_type: :customer}
  )
|> Support.AshApi.create!()


Support.User
|> Ash.Changeset.for_create(
    :create, %{first_name: "Nyima", last_name: "Sönam", email: "nyima@example.com", account_type: :employee}
  )
|> Support.AshApi.create!()
```

Hmm - we can still create a customer as admin and employees without an employee title.  We can also create multiple accounts with the same email address, but at the moment we are not persisting our data, so we can't yet control for that.


### Custom Actions

CRUD is nice, but it is often nice to create an API that focuses on your business logic.  Custom [Actions](https://hexdocs.pm/ash/Ash.Resource.Actions.html) allow us to do that.

We want to add a custom user `create` actions for 'customers', 'employees' and 'admins'.  Thus we will focus on [Create Actions](https://hexdocs.pm/ash/Ash.Resource.Actions.Create.html)

NOTE: at the moment we have no data layer (persistence), so we can only create data.  To verify this try:

Try:
```elixir
iex -S mix phx.server

Support.AshApi.read!(Support.User)
# You should get an error - that says: 'there is no data to be read for that resource'
```

Let's start by just restricting what data can be submitted for various types of accounts. This will force the use of defaults - thus ensuring correct creation.

```elixir
# lib/support/resources/user.ex
# ...
  actions do
    # By default all attributes are accepted by an action
    defaults [:create, :read, :update, :destroy]

    # By default all attributes are accepted by an action
    create :new_customer do
      # only allows the listed attributes
      accept [:email, :first_name, :middle_name, :last_name]
    end
    create :new_employee do
      # only allows the listed attributes
      accept [:email, :first_name, :middle_name, :last_name, :department_name, :account_type]
    end
    create :new_admin do
      # only allows the listed attributes
      accept [:email, :first_name, :middle_name, :last_name, :department_name, :account_type, :admin]
    end
  end
# ...
```

To create a customer now -- the following should should help create a customer correctly:
```elixir
iex -S mix phx.server
# just in case iex is already open
recompile()

# should work
customer = (
  Support.User
  |> Ash.Changeset.for_create(:new_customer, %{first_name: "Nyima", last_name: "Sönam", email: "nyima@example.com"})
  |> Support.AshApi.create!()
)
# the custom action should prevent customers from becoming admins or employees
customer = (
  Support.User
  |> Ash.Changeset.for_create(:new_customer, %{first_name: "Nyima", last_name: "Sönam", email: "nyima@example.com", admin: true})
  |> Support.AshApi.create!()
)
# and get the error:
** (Ash.Error.Invalid) Input Invalid

* Invalid value provided for admin: cannot be changed.
```

## Data Layer (Persistance)

In order to read, update and generally execute queries we will add persistance.  We will start with an OTP based method using (ETS) in memory persistance.  In a separate tutorial we will switch to PostgreSQL.

ETS is an in-memory (OTP based) way to persist data (we will work with PostgreSQL later).
Once we have persisted data we can explore relationships.

To add ETS to the Data Layer we need to change the line `use Ash.Resource` to:
```elixir
# lib/support/resources/user.ex
defmodule Support.User do
  use Ash.Resource,
    data_layer: Ash.DataLayer.Ets
  # ...
end
```

Lets try this out - we will create several user and then query for them.
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
                       department_name: "Office Actor", account_type: :employee}
    )
  |> Support.AshApi.create!()
)
admin = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_admin, %{first_name: "Karma", last_name: "Sönam", email: "karma@example.com",
                    department_name: "Office Admin", account_type: :employee, admin: true}
    )
  |> Support.AshApi.create!()
)

# now we should be able to 'read' all our users:
Support.AshApi.read!(Support.User)
```

## Ash Queries

Zach is clear that he was not interested in recreating something like Active Record.  [Ash Queries](https://hexdocs.pm/ash/Ash.Query.html) are quite flexible.  For now we will start with [filters](https://hexdocs.pm/ash/Ash.Filter.html), [sort](https://hexdocs.pm/ash/Ash.Query.html#sort/3) and [select](https://hexdocs.pm/ash/Ash.Query.html#select/3).  However, there are many [Query Functions](https://hexdocs.pm/ash/Ash.Query.html#functions) available -- including `sort`, `distinct`, `aggregate`, `calculate`, `limit`, `offset`, `subset_of`, etc (more or less any Query mechanism needed).  The nice thing is that this functions with all Data Layer, ETS, SQL, Mnesia, etc.

To learn more visit:
* [Ash Queries](https://hexdocs.pm/ash/Ash.Query.html)
* [Ash Queries](https://www.ash-hq.org/docs/module/ash/2.4.1/ash-query)
* [Writing an Ash Filter](https://www.ash-hq.org/docs/module/ash/2.4.1/ash-filter)

### Critical Query Functions

```elixir
require Ash.Query

# a simple 'read' returns ALL users:
Support.AshApi.read!(Support.User)

# don't return duplicate emails
Support.User
|> Ash.Query.new()
|> Ash.Query.distinct(query, :email)
|> Support.AshApi.read!()

# we can sort the results with:
Support.User
|> Ash.Query.sort([last_name: :desc, first_name: :asc])
|> Support.AshApi.read!()

# we can limit our results to the first value - with a limit 1
Support.User
|> Ash.Query.sort([last_name: :desc, first_name: :asc])
|> Ash.Query.limit(1)
|> Support.AshApi.read!()

# with filter we can return users with 'Office' within the department_name
Support.User
|> Ash.Query.filter(contains(department_name, "Office"))
|> Support.AshApi.read!()

# we can add multiple filters and build complex filters
Support.User
|> Ash.Query.filter(contains(department_name, "Office"))
|> Ash.Query.filter(account_type == :employee and not(contains(department_name, "Admin")))
|> Support.AshApi.read!()

# we can limit what values are returned with select
Support.User
|> Ash.Query.filter(contains(department_name, "Office"))
|> Ash.Query.filter(account_type == :employee and not(contains(department_name, "Admin")))
|> Ash.Query.sort([last_name: :desc, first_name: :asc])
|> Ash.Query.limit(1)
|> Ash.Query.select([:first_name, :last_name])
|> Support.AshApi.read!()
# notice our return only contains id, first_name and last_name now
[
  #Support.User<
    __meta__: #Ecto.Schema.Metadata<:loaded>,
    id: "23bb05e1-936a-4dc6-94b4-a2123a37eb65",
    email: nil,
    first_name: "Nyima",
    middle_name: nil,
    last_name: "Sönam",
    admin: nil,
    account_type: nil,
    department_name: nil,
    inserted_at: nil,
    updated_at: nil,
    aggregates: %{},
    calculations: %{},
    __order__: nil,
    ...
  >
]
```

### Calculated Queries

[Calculated Queries](https://hexdocs.pm/ash/calculations.html) allow us the logic to extend our resources - and with SQL as the Data Layer, these will generate SQL to do the work instead of elixir code!

The simplest way to create a calculation is to add it to the model - for example:
```elixir
# lib/support/resources/user.ex
# ...
  calculations do
    calculate :full_name, :string, expr(first_name <> " " <> last_name)
    # calculate :formal_name, :string, expr(
    #   last_name  <> ", " <> (
    #                           [first_name, middle_name]
    #                           |> Enum.map(fn string -> is_binary(string) end)
    #                           |> Enum.join(" ")
    #                         )
    # )
  end
  # ...
end
```

Then we can retrieve the calculation with the - 'calculate' and 'load' functions:
```elixir
require Ash.Query

# we can get the calculated resource field with - 'calculate' and 'load':
Support.User
|> Ash.Query.new()
|> Ash.Query.calculate(full_name)
|> Ash.Query.load([:full_name])
|> Support.AshApi.read!()
# you should get something like:
[
  #Support.User<
    full_name: "Nyima Sönam",
    aggregates: %{},
    calculations: %{},
    ...
  >,
...
]

# calucated results can be sorted upon and otherwise used in the query
Support.User
|> Ash.Query.new()
|> Ash.Query.calculate(full_name)
|> Ash.Query.load([:full_name])
|> Ash.Query.sort(full_name: :asc)
|> Support.AshApi.read!()
# you should get something like:
[
  #Support.User<
    full_name: "Nyima Sönam",
    aggregates: %{},
    calculations: %{},
    ...
  >,

# on the fly calculations - don't work, I must be overlooking something
# Support.User
# |> Ash.Query.new()
# |> Ash.Query.calculate(:both_names, :string, expr(first_name <> " " <> last_name))
# |> Ash.Query.load([:full_name])
# |> Support.AshApi.read!()
```


### Validations

It bothers me that I can't yet strictly enforce that emails must be unique and require a department_name for all employee accounts.

Let's create some custom validations that accomplishes that.

Validation Documentation is found here:
* [Resource Validations](https://hexdocs.pm/ash/Ash.Resource.Validation.html)
* [Module Docs](https://www.ash-hq.org/docs/module/ash/2.4.2/ash-resource-validation#module-docs)
* [On Changes Tutorial](https://hexdocs.pm/ash/validate-changes.html)
* [Built-In Validations](https://www.ash-hq.org/docs/module/ash/latest/ash-resource-validation-builtins#module-docs)

In oder to do this we will need to allow use to add validation extensions `Ash.Registry.ResourceValidations` to Resources (easiest done in our Registry - which enables validations for all our resources -- more are coming):
```elixir
# lib/support/registry.ex
defmodule Support.Registry do
  use Ash.Registry
    extensions: [
      Ash.Registry.ResourceValidations
    ]

  entries do
    entry Support.User
  end
end
```

#### Absent

Attribute must be absent

Now let's build our Custom Validation - the [document](https://hexdocs.pm/ash/Ash.Resource.Validation.html), to do this we add a present validation with a where clause that tests for our specific conditions.
```elixir
# lib/support/resources/user.ex
  validations do
    validate absent([:department_name]), where: attribute_equals(:account_type, :customer)
    validate present([:department_name]), where: attribute_equals(:account_type, :employee), on: [:create, :update]
    validate attribute_equals(:account_type, :employee), where: attribute_equals(:admin, true)
  end
```


Lets try this out - we will create several user and then query for them.
```elixir
iex -S mix phx.server

# test department_name is absent
customer = (
  Support.User
  |> Ash.Changeset.for_create(
      :create, %{first_name: "Ratna", last_name: "Sönam", email: "ratna@example.com",
                 department_name: "Office Actor", account_type: :customer}
    )
  |> Support.AshApi.create!()
)
# now we should expect the following error
** (Ash.Error.Invalid) Input Invalid

* department_name: must be absent.

# but this should still work
customer = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_customer, %{first_name: "Ratna", last_name: "Sönam", email: "ratna@example.com"}
    )
  |> Support.AshApi.create!()
)
```

#### Present

Attribute must be present

```elixir
iex -S mix phx.server

employee = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_employee, %{first_name: "Nyima", last_name: "Sönam", email: "ratna@example.com",
                       department_name: "Office Actor", account_type: :employee}
    )
  |> Support.AshApi.create!()
)
# we should get this error
** (Ash.Error.Invalid) Input Invalid

* email: has already been taken.


employee = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_employee, %{first_name: "Nyima", last_name: "Sönam", email: "nyima@example.com",
                       department_name: "Office Actor", account_type: :employee}
    )
  |> Support.AshApi.create!()
)
admin = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_admin, %{first_name: "Karma", last_name: "Sönam", email: "karma@example.com",
                    department_name: "Office Admin", account_type: :employee, admin: true}
    )
  |> Support.AshApi.create!()
)
```

#### Attribute Equals



### Uniqueness (Identity)

In order to ensure that the email is a unique identifier - we use the `identities` feature.  Unfortunately, this feature behaves differently depending on the Data Layer in use.  In particular, from the docs, we see
  Ash.DataLayer.Ets will actually require you to set pre_check_with since the ETS data layer has no built in support for unique constraints.

In order to
```elixir
  identities do
    identity :email, [:email], pre_check_with: Support.AshApi
    identity :full_name, [:first_name, :middle_name, :last_name], pre_check_with: Support.AshApi
  end
```

```elixir
iex -S mix phx.server

customer = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_customer, %{first_name: "Ratna", last_name: "Sönam", email: "ratna@example.com"}
    )
  |> Support.AshApi.create!()
)
employee = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_employee, %{first_name: "Nyima", last_name: "Sönam", email: "ratna@example.com",
                       department_name: "Office Actor", account_type: :employee}
    )
  |> Support.AshApi.create!()
)
# we should get this error
** (Ash.Error.Invalid) Input Invalid

* email: has already been taken.

# But the following should work
employee = (
  Support.User
  |> Ash.Changeset.for_create(
      :new_employee, %{first_name: "Nyima", last_name: "Sönam", email: "nyima@example.com",
                       department_name: "Office Actor", account_type: :employee}
    )
  |> Support.AshApi.create!()
)
```


# Resources

* https://www.youtube.com/watch?v=2U3vQHXCF0s
* https://hexdocs.pm/ash/relationships.html#loading-related-data
* https://www.ash-hq.org/docs/guides/ash/2.4.1/tutorials/get-started.md
* https://github.com/phoenixframework/phoenix/blob/master/installer/README.md
* https://speakerdeck.com/zachsdaniel1/introduction-to-the-ash-framework-elixir-conf-2020?slide=6

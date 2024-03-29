---
layout: post
title:  Ash 2.1 Tutorial - 00 Introduction
subtitle: Overview
date:   2022-11-04 01:59:53 +0200
updated:   2022-11-05 01:59:53 +0200
slug: elixir
publish: true
categories: elixir phoenix ash
excerpt: Beginner's guide to the Ash framework - Introduction and Project Setup
---

**Ash Framework 2.1 - A Beginner's Tutorial**
1. [Introduction](/elixir/ash_2_1_tutorial-00_introduction/)
2. [Resources](/elixir/ash_2_1_tutorial-01_resources/)
3. [Data-Layer](/elixir/ash_2_1_tutorial-02_data_layer/)
4. [Relationships](elixir/ash_2_1_tutorial-03_relationships/)
5. Authentication
6. Authorization
7. Architecture
8. Engines & Flow
9. LiveView
10. GraphQL
11. JSON API


**Note:** it is expected that you are already familiar with Elixir (but you need not be an expert)

[Ash Framework](https://ash-hq.org/) is a declarative, resource-oriented application development framework for [Elixir](https://elixir-lang.org/). A resource can model anything, like a database table, an external API, or even custom code.

I've been curious about the Elixir Ash Framework and with the current 'stable' release, I decided to spend part of my vacation to explore and hopefully learn Ash.

## Purpose

This tutorial tries to build on existing tutorials and documentation on Ash and present enough code examples and explanations, that a beginner (like me), can successfully build an application.

The idea is to build a relatively simple Ash app (a Support Ticket system), and integrate it with a Phoenix web application.  And then provide alternative API (GraphQL / Json) - to make the app available to say a mobile App.

## Overview

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

However, I like to think of Ash as having four Layers:
* **Engines** - The Ash engine handles the parallelization/running of requests to Ash.
* **Application APIs** - external access to data and actions (AshActions, AshJsonAPI, AshGraphQL, etc)
* **Resources** - a description of what should happen (actions allowed and the data required)
* **Data Layer** - data persistence (in memory, ETS, Mnesia, PostgreSQL, etc)


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

## Ash Structure

Long-term our system will need users, tickets and comments.

For now we need to create the minimal infrastructure needed by Ash, this includes:
* An Ash **Resource** - the core workable aspects of our data and its associated information.
* An Ash **Registry** - of the Resources and extension the API has access to (basically binds the application together).
* An Ash **Api** - ways to access and manipulate our Resources


----------

Now you can continue on with [Ash Framework 2.1 Tutorial - 01 Resources](/elixir/ash_2_1_tutorial_01_resources/) - where we will start the back-bone of an Ash application - the resources.

----------

# Resources

**Documentation**
* https://www.ash-hq.org/
* https://hexdocs.pm/ash/get-started.html
* https://www.ash-hq.org/docs/guides/ash/2.4.1/tutorials/get-started.md
* https://github.com/phoenixframework/phoenix/blob/master/installer/README.md

**Ash Framework 1.5** - Video and Slides
* https://www.youtube.com/watch?v=2U3vQHXCF0s
* https://speakerdeck.com/zachsdaniel1/introduction-to-the-ash-framework-elixir-conf-2020?slide=6

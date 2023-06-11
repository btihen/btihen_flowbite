---
layout: post
title:  "Ash 2.1 Tutorial - 07 JSON API"
date:   2022-11-04 01:59:53 +0200
updated:   2022-11-05 01:59:53 +0200
slug: elixir
publish: true
categories: elixir phoenix ash
excerpt: Adding a JSON API to Ash
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
      {:ash_json_api, "~> 0.31.1"},
```

Update the Support API definition to include json
```elixir
# lib/helpdesk/support.ex
defmodule Helpdesk.Support do
  use Ash.Api,
    extensions: [
      # This extension adds helpful compile time validations
      AshJsonApi.Api
    ]

  resources do
    # This defines the set of resources that can be used with this API
    registry Helpdesk.Support.Registry
  end
end
```

Update Phoenix to find the JSON api
```elixir
# routes.ex
scope "/api" do
  pipe_through :api
  AshJsonApi.forward("/", Helpdesk.Support)
end
```


## Resources

* https://github.com/ash-project/ash_json_api
* https://hexdocs.pm/ash_json_api/AshJsonApi.html#summary

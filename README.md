# ConduitPlugs

A collection of plugs to work with `conduit`.

## Installation

The package can be installed by adding `conduit_plugs` to your list of
dependencies in `mix.exs` via `git`:

```elixir
def deps do
  [
    {:conduit_plugs, git: "https://github.com/DigixGlobal/conduit_plugs"}
  ]
end
```

## Serialization

If you need to make use of JSON serialization via
[Jason](https://github.com/michalmuskala/jason), add this to your config:

```elixir
config :conduit, Conduit.Encoding, [
  {"json", ConduitPlugs.Encoding.Json}
]
```

You can use this via `Conduit.Plug`s like so:

```elixir
  pipeline :serialize do
    plug(Conduit.Plug.Encode, content_encoding: "json")
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Decode, content_encoding: "json")
  end
```

## Plugs

It is recommended to setup some common pipelines to use the other plugs:

```elixir
# JSON Seriliazer from `ConduitPlugs.Encoding.Json`
config :conduit, Conduit.Encoding, [
  {"json", ConduitPlugs.Encoding.Json}
]

defmodule MyAppBroker do
  # ...

  pipeline :serialize do
    plug(Conduit.Plug.Wrap)         # Put meta fields in `:body`
    plug(Conduit.Plug.Encode,       # Pick your serializer
      content_encoding: "json")     #   JSON is a good default
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Decode,       # Put the corresponding deserializer
      content_encoding: "json")
    plug(Conduit.Plug.Unwrap)       # Unwrap meta fields from `:body`
  end
end
```

### ConduitPlugs.Deduplication

Prevents messages from being handled more than once by checking the
message ID. To use, add this in your supervision tree or application
children:

```elixir
Supervisor.start_link([
  ConduitPlugs.Deduplication
])
```

It is recommended to setup your broker pipelines like so:

```elixir
defmodule MyApp.Broker do
  use Conduit.Broker, otp_app: :my_app

  configure do
    # ...
  end

  pipeline :dedup_meta do
    plug(Conduit.Plug.MessageId)     # Put `:message_id` field
  end

  pipeline :dedup do                 # PLUG HERE
    plug(ConduitPlugs.Deduplication,
      ttl: :timer.hours(12)          # Set the TTL to a reasonable time
  end


  incoming MyApp do
    pipe_through([:dedup_meta, :deserialize])  # Add meta before serializing

    # ...
  end

  outgoing do
    pipe_through([:serialize, :dedup])         # Deduplication should be last

    # ...
  end
end
```

### Options

Plug specific option

- `:ttl`(Optional) - Expiration time of the message ID before it can be
  used again. If not specified, it defaults to the config `:default_ttl`

Config sepcific option

```elixir
  config :conduit_plugs, ConduitPlugs.Deduplication,
    default_ttl: :timer.seconds(60),
    default_ttl_interval: :timer.seconds(30)
```

- `:default_ttl` (Optional) - Default expiration time for every message
  ID. (Default: `60_000`)
- `:default_ttl_interval` (Optional) - Sweep interval to remove expired
  message IDs. This is based on [Cachex TTL
  Implementation](https://hexdocs.pm/cachex/ttl-implementation.html#content).
  (Default: `default_ttl / 2`)

defmodule ConduitPlugs.Deduplication do
  @moduledoc """
  Prevents messages from being handled (not received) more than once by
  checking the message ID. If no message ID is set, it passes the
  message through. It is suggested to use `Conduit.Plug.MessageId`
  before this plug to have an auto-generated message ID.

  This works by storing the message ID in a time-based cache which can
  be configured via `:ttl` option or globally with `:default_ttl`
  config. When an error occurs in handling the message, retried messages
  are no longer handled. It is suggested to let this plug be the last or
  near the end or before the error handling plugs.

  ## Examples

      plug ConduitPlugs.Deduplication
      plug ConduitPlugs.Deduplication, ttl: 15_000   # In microseconds

  """

  use Conduit.Plug.Builder

  require Logger

  alias Cachex

  @cache_name :deduplication_cache

  defmodule Cache do
    @moduledoc false

    use Supervisor

    alias Cachex

    @cache_name :deduplication_cache
    @default_ttl 60_000

    def start_link(opts) do
      Supervisor.start_link(__MODULE__, opts)
    end

    @impl true
    def init(_opts) do
      import Supervisor.Spec
      import Cachex.Spec

      opts = Application.get_env(:conduit_plugs, ConduitPlugs.Deduplication, [])
      default_ttl = Keyword.get(opts, :default_ttl, @default_ttl)

      default_interval =
        Keyword.get_lazy(opts, :default_ttl_interval, fn ->
          round(default_ttl / 2)
        end)

      children = [
        worker(Cachex, [
          @cache_name,
          [
            expiration:
              expiration(
                default: default_ttl,
                interval: default_interval
              )
          ]
        ])
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end

  @doc false
  def call(message, next, opts) do
    if id = Map.get(message, :message_id, nil) do
      Cachex.execute(@cache_name, fn worker ->
        worker
        |> Cachex.exists?(id)
        |> elem(1)
        |> case do
          true ->
            message
            |> Map.update!(
              :private,
              &Map.put(&1, :deduped, true)
            )

          false ->
            Cachex.put(worker, id, true, ttl: Keyword.get(opts, :ttl, nil))

            next.(message)
        end
      end)
      |> elem(1)
    else
      next.(message)
    end
  end
end

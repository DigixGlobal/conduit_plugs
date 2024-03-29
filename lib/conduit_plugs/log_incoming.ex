defmodule ConduitPlugs.LogIncoming do
  use Conduit.Plug.Builder

  require Logger

  @moduledoc """
  Logs an incoming message and how long it takes to process it.

  This is intended to be used in an incoming pipeline or subscriber.

  ## Examples

      plug Conduit.Plug.LogIncoming
      plug Conduit.Plug.LogIncoming, log: :debug

  """

  def call(message, next, opts) do
    level = Keyword.get(opts, :log, :info)
    start = System.monotonic_time()

    try do
      Logger.log(level, fn ->
        ["Processing message from ", to_string(message.source)]
      end)

      next.(message)
    rescue
      error ->
        Logger.log(:error, Exception.format(:error, error))
        reraise error, System.stacktrace()
    after
      Logger.log(level, fn ->
        stop = System.monotonic_time()
        diff = System.convert_time_unit(stop - start, :native, :microsecond)

        ["Processed message from ", to_string(message.source), " in ", formatted_diff(diff)]
      end)
    end
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string(), "ms"]
  defp formatted_diff(diff), do: [diff |> Integer.to_string(), "µs"]
end

defmodule ConduitPlugs do
  @moduledoc """
  A set of useful plugs and helpers when using `conduit`.
  """

  alias Conduit.Message

  @doc """
  Marks a message with a private flag, `:handled`.

  This makes testing messages easier by knowing the message is handled
  by a consumer with this flag.

  ## Example

      iex> ConduitPlugs.mark_handled(%Conduit.Message{})
      %Conduit.Message{
        assigns: %{},
        body: nil,
        content_encoding: nil,
        content_type: nil,
        correlation_id: nil,
        created_at: nil,
        created_by: nil,
        destination: nil,
        headers: %{},
        message_id: nil,
        private: %{handled: true},
        source: nil,
        status: :ack,
        user_id: nil
      }

  """
  @spec mark_handled(Message.t()) :: Message.t()
  def mark_handled(message) do
    message
    |> Map.update(:private, %{handled: true}, &Map.put(&1, :handled, true))
  end

  @doc

  @doc """
  Checks if a message is handled with the private flag, `:handled`.

  ## Example

      iex> %Conduit.Message{} |> ConduitPlugs.mark_handled() |> ConduitPlugs.marked?()
      true

      iex> %Conduit.Message{} |> ConduitPlugs.marked?()
      false

  """
  @spec marked?(Message.t()) :: boolean()
  def marked?(message) do
    message
    |> Map.get(:private, %{})
    |> Map.get(:handled, false)
  end
end

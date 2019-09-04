defmodule ConduitPlugs.Test do
  @moduledoc """
  Macros and helpers to help in testing.
  """

  @doc """
  Simple assertion if a message is handled.
  """
  defmacro assert_message_handled(message) do
    quote do
      assert match?(%Conduit.Message{private: %{handled: true}}, unquote(message))
    end
  end

  @doc """
  Complementary to `assert_message_handled`, asserts if a message is
  unhandled.
  """
  defmacro refute_message_handled(message) do
    quote do
      refute match?(%Conduit.Message{private: %{handled: true}}, unquote(message))
    end
  end

end

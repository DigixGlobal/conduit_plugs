defmodule BeDeduped do
  use ESpec.Assertions.Interface

  alias Conduit.Message

  def match(%Message{private: private}, _data) do
    {match?(%{deduped: true}, private), private}
  end

  def success_message(subject, _value, _result, positive) do
    to = if positive, do: "is", else: "is not"
    "`message##{subject.message_id}` #{to} deduplicated."
  end

  def error_message(subject, _value, _result, positive) do
    to = if positive, do: "to", else: "not to"
    "Expected `message##{subject.message_id}` #{to} be deduplicated"
  end
end

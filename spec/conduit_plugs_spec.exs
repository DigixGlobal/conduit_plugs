defmodule ConduitPlugsSpec do
  @moduledoc false

  use ESpec

  alias Conduit.Message

  alias ConduitPlugs, as: DescribedModule
  import ConduitPlugs.Test

  describe "ConduitPlugs" do
    def handled_message() do
      %Message{}
      |> DescribedModule.mark_handled()
    end

    def unhandled_message() do
      %Message{}
    end

    describe "mark_handled/1" do
      it "should work" do
        handled_message()
        |> expect()
        |> to(match_pattern(%Message{private: %{handled: true}}))
      end
    end

    describe "marked?/1" do
      it "should work with handled message" do
        handled_message()
        |> DescribedModule.marked?()
        |> expect()
        |> to(be_true())
      end

      it "should work with unhandled message" do
        unhandled_message()
        |> DescribedModule.marked?()
        |> expect()
        |> to(be_false())
      end
    end

    describe "assert_message_handled/1" do
      it "should work positively" do
        assert_message_handled(handled_message())
      end

      it "should work negatively" do
        refute_message_handled(unhandled_message())
      end
    end
  end
end

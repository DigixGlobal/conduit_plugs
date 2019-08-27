defmodule ConduitPlugs.DeduplicationSpec do
  use ESpec
  import DeduplicationAssertions

  alias Conduit.Message

  alias ConduitPlugs.Deduplication

  describe "Deduplication" do
    before_all do
      Deduplication.Cache.start_link([])
    end

    def create_message(id \\ nil) do
      %Message{message_id: id || :random.uniform(), body: "#{DateTime.utc_now()}"}
    end

    it "should dedup" do
      message = create_message()

      message
      |> described_module().run([])
      |> expect()
      |> to_not(be_deduped())

      message
      |> described_module().run([])
      |> to(be_deduped())
    end

    it "should pass empty message Id" do
      message = create_message("")

      message
      |> described_module().run([])
      |> expect()
      |> to_not(be_deduped())
    end

    it "should allow other messages" do
      message = create_message()
      other_message = create_message()

      message
      |> described_module().run([])
      |> expect()
      |> to_not(be_deduped())

      other_message
      |> described_module().run([])
      |> to_not(be_deduped())
    end

    it "TTL should expire" do
      message = create_message()
      interval = Application.get_env(:conduit_plugs, ConduitPlugs.Deduplication)[:default_ttl_interval]
      ttl = interval + :rand.uniform(3000)

      message
      |> described_module().run([ttl: ttl])
      |> expect()
      |> to_not(be_deduped())

      Process.sleep(ttl - interval)

      message
      |> described_module().run([])
      |> expect()
      |> to(be_deduped())

      Process.sleep(2 * interval)

      message
      |> described_module().run([])
      |> expect()
      |> to_not(be_deduped())
    end
  end
end

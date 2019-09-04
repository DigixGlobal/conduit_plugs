import Config

if Mix.env() == :test do
  config :conduit_plugs, ConduitPlugs.Deduplication, default_ttl_interval: 500
end

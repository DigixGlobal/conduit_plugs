defmodule ConduitPlugs.MixProject do
  use Mix.Project

  def project do
    [
      app: :conduit_plugs,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [
        tool: Coverex.Task,
        coveralls: true
      ],
      preferred_cli_env: [espec: :test]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "spec"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:conduit, "0.12.10"},
      {:cachex, "~> 3.2"},
      {:jason, "~> 1.1.0", optional: true},
      {:coverex, "~> 1.4.10", only: :test},
      {:espec, "~> 1.7.0", only: :test},
      {:quixir, "~> 0.9", only: :test}
    ]
  end

  defp aliases do
    [
      test: "espec"
    ]
  end
end

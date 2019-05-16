defmodule Safeboda.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      preferred_cli_env: [
        release: :prod
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:stream_data, "~> 0.1", only: :test},
      {:git_hooks, "~> 0.3.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"]
    ]
  end
end

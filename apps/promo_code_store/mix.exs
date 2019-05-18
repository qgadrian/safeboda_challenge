defmodule SafeBoda.PromoCodeStore.MixProject do
  use Mix.Project

  def project do
    [
      app: :promo_code_store,
      version: "0.1.0",
      aliases: aliases(),
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.8",
      elixirc_options: [warnings_as_errors: true],
      elixirc_paths: elixirc_paths(Mix.env()),
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SafeBoda.PromoCodeStore.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases() do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:promo_code_generator, in_umbrella: true}
    ]
  end
end

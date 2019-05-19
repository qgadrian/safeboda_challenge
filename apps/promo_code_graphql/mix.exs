defmodule SafeBoda.PromoCode.Graphql.MixProject do
  use Mix.Project

  def project do
    [
      app: :promo_code_graphql,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_relay, "~> 1.4"},
      {:promo_code_store, in_umbrella: true},
      {:promo_code_generator, in_umbrella: true, only: :test}
    ]
  end
end

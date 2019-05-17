defmodule SafeBoda.PromoCodeModel.MixProject do
  use Mix.Project

  def project do
    [
      app: :promo_code_model,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps: deps(),
      deps_path: "../../deps",
      elixir: "~> 1.8",
      elixirc_options: [warnings_as_errors: true],
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SafeBoda.PromoCodeModel.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:stream_data, "~> 0.4.3", only: :test}
    ]
  end
end

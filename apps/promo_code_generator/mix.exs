defmodule SafeBoda.PromoCode.Generator.MixProject do
  use Mix.Project

  def project do
    [
      app: :promo_code_generator,
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
      extra_applications: [:logger, :stream_data]
    ]
  end

  defp deps do
    [
      {:stream_data, "~> 0.4.3", only: :test}
    ]
  end
end

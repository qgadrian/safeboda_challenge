defmodule Safeboda.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
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
    []
  end
end

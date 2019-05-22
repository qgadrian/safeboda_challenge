defmodule Safeboda.MixProject do
  use Mix.Project

  def project do
    [
      name: "Safeboda",
      apps_path: "apps",
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [
        release: :prod
      ]
    ]
  end

  defp docs do
    [
      main: "README",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:git_hooks, "~> 0.3.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"],
      docs: ["docs", &copy_images/1]
    ]
  end

  defp copy_images(_) do
    File.cp_r!("static", "doc/static")
  end
end

use Mix.Config

config :promo_code_model, ecto_repos: [SafeBoda.PromoCodeModel.Repo]

config :promo_code_model, SafeBoda.PromoCodeModel.Repo,
  database: "safeboda",
  username: "admin",
  password: "changeme",
  hostname: "localhost",
  port: "5432"

use Mix.Config

config :promo_code_store, ecto_repos: [SafeBoda.PromoCodeStore.Repo]

config :promo_code_store, SafeBoda.PromoCodeStore.Repo,
  database: "safeboda",
  username: "admin",
  password: "changeme",
  hostname: "localhost",
  port: "5432"

if Mix.env() == :test do
  import_config "#{Mix.env()}.exs"
end

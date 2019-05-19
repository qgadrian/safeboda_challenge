use Mix.Config

config :promo_code_store, SafeBoda.PromoCodeStore.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "safeboda_test"

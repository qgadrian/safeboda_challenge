use Mix.Config

config :promo_code_web,
  namespace: SafeBoda.PromoCodeWeb,
  generators: [context_app: false]

# Configures the endpoint
config :promo_code_web, SafeBoda.PromoCodeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cDac0dY1smLQhL8858xJx7949rXvfVVKNJVp1wFV1oPD+zgDhlEDcgwXbGw4oUe5",
  render_errors: [view: SafeBoda.PromoCodeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SafeBoda.PromoCodeWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason

config :promo_code_web, SafeBoda.PromoCodeWeb.Endpoint,
  live_view: [
    signing_salt: "8wtjyO2ywGb0KUaoUmHl1Aydt14Asqgr"
  ]

import_config "#{Mix.env()}.exs"

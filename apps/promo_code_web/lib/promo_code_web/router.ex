defmodule SafeBoda.PromoCodeWeb.Router do
  use SafeBoda.PromoCodeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", SafeBoda.PromoCodeWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/all", PromoCodeController, :all)
    get("/all_active", PromoCodeController, :all_active)
    # Validations
    get("/validate", PromoCodeController, :validate)
    post("/validate", PromoCodeController, :do_validate)
  end

  scope "/" do
    if Mix.env() == :dev do
      forward(
        "/graphql",
        Absinthe.Plug.GraphiQL,
        schema: SafeBoda.PromoCode.Graphql
      )
    else
      forward(
        "/graphql",
        Absinthe.Plug,
        schema: SafeBoda.PromoCode.Graphql
      )
    end
  end
end

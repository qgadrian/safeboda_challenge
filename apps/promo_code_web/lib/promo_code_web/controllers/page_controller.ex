defmodule SafeBoda.PromoCodeWeb.PageController do
  use SafeBoda.PromoCodeWeb, :controller

  alias SafeBoda.PromoCodeStore

  def index(conn, _params) do
    with promo_codes <- PromoCodeStore.all() do
      render(conn, "index.html", promo_codes: promo_codes)
    end
  end
end

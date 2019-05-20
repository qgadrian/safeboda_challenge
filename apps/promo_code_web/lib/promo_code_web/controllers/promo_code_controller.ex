defmodule SafeBoda.PromoCodeWeb.PromoCodeController do
  use SafeBoda.PromoCodeWeb, :controller

  alias SafeBoda.PromoCodeStore

  def all(conn, _params) do
    with promo_codes <- PromoCodeStore.all() do
      render(conn, "all.html", promo_codes: promo_codes)
    end
  end

  def all_active(conn, _params) do
    with promo_codes <- PromoCodeStore.all_active() do
      render(conn, "all_active.html", promo_codes: promo_codes)
    end
  end
end

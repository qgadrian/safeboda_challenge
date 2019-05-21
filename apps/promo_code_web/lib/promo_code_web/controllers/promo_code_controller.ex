defmodule SafeBoda.PromoCodeWeb.PromoCodeController do
  use SafeBoda.PromoCodeWeb, :controller

  alias SafeBoda.PromoCodeStore
  alias SafeBoda.PromoCodeStore.Location
  alias SafeBoda.PromoCodeStore.Schema.PromoCode

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

  def view(conn, _params) do
    with {:ok, promo_code} <- PromoCodeStore.get(conn.params["code"]),
         promo_code <- PromoCode.changeset(promo_code) do
      render(conn, "new.html", promo_code: promo_code)
    end
  end

  def validate(conn, _params) do
    render(conn, "validate.html")
  end

  def do_validate(conn, _params) do
    code = conn.params["validation"]["code"]

    pickup = %Location{
      latitude: parse_float(conn.params["validation"]["pickup_latitude"]),
      longitude: parse_float(conn.params["validation"]["pickup_longitude"])
    }

    destination = %Location{
      latitude: parse_float(conn.params["validation"]["destination_latitude"]),
      longitude: parse_float(conn.params["validation"]["destination_longitude"])
    }

    with {:ok, promo_code} <- PromoCodeStore.validate(code, pickup, destination) do
      render(conn, "validate.html", promo_code: promo_code)
    else
      {:error, :not_valid} ->
        render(conn, "validate.html", error: :not_valid)

      {:error, :not_found} ->
        render(conn, "validate.html", error: :not_found)
    end
  end

  def new(conn, _params) do
    promo_code = PromoCode.changeset(%PromoCode{}, %{})
    render(conn, "new.html", promo_code: promo_code)
  end

  def create(conn, _params) do
    with {:ok, promo_code} <- PromoCodeStore.new(conn.params["promo_code"]) do
      render(conn, "view.html", promo_code: promo_code)
      # TODO return form with errors
    end
  end

  def update(conn, _params) do
    params =
      conn.params
      |> Map.get("promo_code")
      |> Map.take(["code", "active?", "minimum_event_radius"])

    with {:ok, promo_code} <- PromoCodeStore.get(params["code"]),
         promo_code <- PromoCode.changeset(promo_code, params),
         {:ok, promo_code} <- PromoCodeStore.update(promo_code) do
      render(conn, "view.html", promo_code: promo_code)
      # TODO return form with errors
    end
  end

  # XXX this function should be in a parser module
  defp parse_float(float_string) do
    {float, ""} = Float.parse(float_string)
    float
  end
end

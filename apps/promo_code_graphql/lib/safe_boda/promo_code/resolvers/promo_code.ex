defmodule SafeBoda.PromoCode.Graphql.Resolvers.PromoCode do
  @moduledoc """
  Contains the resolver functions to provide the promo code information.
  """

  alias SafeBoda.PromoCodeStore
  alias SafeBoda.PromoCodeStore.Location
  alias SafeBoda.PromoCodeStore.PromoCode

  @spec all(term, term) :: {:ok, list(PromoCode.t())}
  def all(_args, _context) do
    promo_codes = PromoCodeStore.all()
    {:ok, promo_codes}
  end

  @spec all_active(term, term) :: {:ok, list(PromoCode.t())}
  def all_active(_args, _context) do
    promo_codes = PromoCodeStore.all_active()
    {:ok, promo_codes}
  end

  @spec validate(term, term) :: {:ok, PromoCode.t()} | {:error, term}
  def validate(args, _context) do
    code = args[:code]
    destination_latitude = args[:destination_latitude]
    destination_longitude = args[:destination_longitude]
    pickup_latitude = args[:pickup_latitude]
    pickup_longitude = args[:pickup_longitude]

    pickup_location = %Location{latitude: pickup_latitude, longitude: pickup_longitude}

    destination_location = %Location{
      latitude: destination_latitude,
      longitude: destination_longitude
    }

    PromoCodeStore.validate(code, pickup_location, destination_location)
  end
end

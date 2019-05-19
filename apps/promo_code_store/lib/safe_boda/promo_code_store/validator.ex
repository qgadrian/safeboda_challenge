defmodule SafeBoda.PromoCodeStore.Validator do
  @moduledoc """
  This module validates the promotional codes.

  A promotion code should meet the following requisites to be applicable for a ride:

  * Should be active
  * The expire date should not be in the past
  * The user pickup or destination position should be included in the radius of
  the event location, provided from the promo code. See (user
  location)[#user-location] for more info.

  ## User location

  In order for a promotional code to be used, geographical restrictions are
  applied.

  When a user wants to use a promo code, it should provide a pickup and a
  destination location. Those locations will be considered when checking the
  are where the promo code could be used.

  Every event has a location coordinates, and the distance of the user's
  pickup/destination and the event's location should be less than the
  promotional code configured radius.
  """

  alias SafeBoda.PromoCodeStore.Location
  alias SafeBoda.PromoCodeStore.Schema.PromoCode

  @doc """
  Checks if a promo code is valid.

  Returns `true` if the promo code can be used, other wise returns `false`. See
  (user location)[#user-location] for more info.
  """
  @spec valid?(PromoCode.t(), Location.t(), Location.t()) :: boolean
  def valid?(
        %PromoCode{} = promo_code,
        %Location{} = pickup,
        %Location{} = destination
      ) do
    promo_code.active? and not expired?(promo_code) and
      inside_radius?(promo_code, pickup, destination)
  end

  @spec expired?(PromoCode.t()) :: boolean
  defp expired?(%PromoCode{} = promo_code) do
    DateTime.utc_now()
    |> DateTime.compare(promo_code.expiration_date)
    |> case do
      :gt -> true
      _ -> false
    end
  end

  @spec inside_radius?(PromoCode.t(), Location.t(), Location.t()) :: boolean
  defp inside_radius?(promo_code, pickup, destination) do
    center_point = [promo_code.event_latitude, promo_code.event_longitude]
    radius = promo_code.minimum_event_radius
    pickup_point = Location.geocalc_point(pickup)
    destination_point = Location.geocalc_point(destination)

    Geocalc.within?(radius, center_point, pickup_point) or
      Geocalc.within?(radius, center_point, destination_point)
  end
end

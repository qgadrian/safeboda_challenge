defmodule SafeBoda.PromoCode.Generator.Location do
  @moduledoc """
  Generates location structs to be used in property based testing.
  """
  use ExUnitProperties

  alias SafeBoda.PromoCodeStore.Location
  alias SafeBoda.PromoCodeStore.Schema.PromoCode

  @doc """
  Returns a generator for `t:#{Location}.t/0`.

  ## Options

  * `max_latitude`: The maximum latitude point.
  * `max_longitude`: The maximum longitude point.
  * `min_latitude`: The minimum latitude point.
  * `min_longitude`: The minimum longitude point.
  """
  @spec generate_location(keyword) :: StreamData.t(Location.t())
  def generate_location(opts \\ []) do
    max_latitude = Keyword.get(opts, :max_latitude, 90)
    max_longitude = Keyword.get(opts, :max_longitude, 180)
    min_latitude = Keyword.get(opts, :min_latitude, -90)
    min_longitude = Keyword.get(opts, :min_longitude, -180)

    gen all latitude <- StreamData.float(min: min_latitude, max: max_latitude),
            longitude <- StreamData.float(min: min_longitude, max: max_longitude) do
      %Location{latitude: latitude, longitude: longitude}
    end
  end

  @doc """
  Returns a generator for `t:#{Location}.t/0`.

  The location generator will be included inside the minimum promo code event
  radius.

  ## Options

  * `latitude_diff`: The +/- difference of the generated latitude from the promo code event, defaults to `5`.
  * `longitude_diff`: The +/- difference of the generated longitude from the promo code event, defaults to `5`.
  """
  @spec generate_promo_location(PromoCode.t(), keyword) :: StreamData.t(Location.t())
  def generate_promo_location(%PromoCode{} = promo_code, opts \\ []) do
    latitude_diff = Keyword.get(opts, :latitude_diff, 5)
    longitude_diff = Keyword.get(opts, :longitude_diff, 5)

    generator_opts = [
      max_latitude: promo_code.event_latitude + latitude_diff,
      max_longitude: promo_code.event_longitude + longitude_diff,
      min_latitude: promo_code.event_latitude - latitude_diff,
      min_longitude: promo_code.event_longitude - longitude_diff
    ]

    gen all location <-
              StreamData.filter(
                generate_location(generator_opts),
                &inside_promo_code?(&1, promo_code)
              ) do
      location
    end
  end

  @spec inside_promo_code?(Location.t(), PromoCode.t()) :: boolean
  defp inside_promo_code?(%Location{} = location, %PromoCode{} = promo_code) do
    center_point = [promo_code.event_latitude, promo_code.event_longitude]
    location_point = Location.geocalc_point(location)

    Geocalc.within?(promo_code.minimum_event_radius, center_point, location_point)
  end
end

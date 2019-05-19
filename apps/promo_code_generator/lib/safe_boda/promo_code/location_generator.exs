defmodule SafeBoda.PromoCode.Generator.Location do
  @moduledoc """
  Generates location structs to be used in property based testing.
  """
  use ExUnitProperties

  alias SafeBoda.PromoCodeStore.Location

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
end

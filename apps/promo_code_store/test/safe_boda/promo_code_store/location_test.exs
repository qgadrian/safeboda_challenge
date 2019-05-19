defmodule SafeBoda.PromoCodeStore.LocationTest do
  use ExUnit.Case
  use ExUnitProperties

  alias SafeBoda.PromoCodeStore.Location

  describe "Given a location point" do
    property "geocalc_point/1 returns a list with the latitude and longitude" do
      check all location <- generate_location() do
        [latitude, longitude] = Location.geocalc_point(location)
        assert latitude == location.latitude
        assert longitude == location.longitude
      end
    end
  end

  defp generate_location() do
    gen all latitude <- StreamData.float(),
            longitude <- StreamData.float() do
      %Location{latitude: latitude, longitude: longitude}
    end
  end
end

defmodule SafeBoda.PromoCodeStore.LocationTest do
  use ExUnit.Case
  use ExUnitProperties

  alias SafeBoda.PromoCodeStore.Location
  alias SafeBoda.PromoCode.Generator.Location, as: LocationGenerator

  describe "Given a location point" do
    property "geocalc_point/1 returns a list with the latitude and longitude" do
      check all location <- LocationGenerator.generate_location() do
        [latitude, longitude] = Location.geocalc_point(location)
        assert latitude == location.latitude
        assert longitude == location.longitude
      end
    end
  end
end

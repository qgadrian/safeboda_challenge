defmodule SafeBoda.PromoCodeStore.ValidatorTest do
  use ExUnit.Case
  use ExUnitProperties
  use SafeBoda.PromoCodeStore.Suppport.RepoCase

  doctest SafeBoda.PromoCodeStore.Validator

  alias SafeBoda.PromoCode.Generator.Location, as: LocationGenerator
  alias SafeBoda.PromoCode.Generator.PromoCode, as: PromoCodeGenerator
  alias SafeBoda.PromoCodeStore.Validator

  describe "Given a promo code" do
    test "valid?/1 returns true for valid promo codes" do
      generator_opts = [
        frequency_inactive: 0,
        frequency_expiration_past: 0,
        max_number_of_rides: 10,
        min_event_radius: 10000
      ]

      location_opts = [
        latitude_diff: 0.01,
        longitude_diff: 0.01
      ]

      check all promo_code <- PromoCodeGenerator.generate_promo_code(generator_opts),
                pickup_location <-
                  LocationGenerator.generate_promo_location(promo_code, location_opts),
                destination_location <- LocationGenerator.generate_location() do
        assert Validator.valid?(promo_code, pickup_location, destination_location)
      end
    end

    test "valid?/1 returns false for inactive promo codes" do
      generator_opts = [
        frequency_active: 0,
        max_number_of_rides: 10,
        min_event_radius: 1000
      ]

      location_opts = [
        latitude_diff: 0,
        longitude_diff: 0
      ]

      check all promo_code <- PromoCodeGenerator.generate_promo_code(generator_opts),
                pickup_location <- LocationGenerator.generate_location(),
                destination_location <-
                  LocationGenerator.generate_promo_location(promo_code, location_opts) do
        refute Validator.valid?(promo_code, pickup_location, destination_location)
      end
    end

    test "valid?/1 returns false for expired promo codes" do
      generator_opts = [
        frequency_expiration_future: 0,
        max_number_of_rides: 10,
        min_event_radius: 1000
      ]

      location_opts = [
        latitude_diff: 0,
        longitude_diff: 0
      ]

      check all promo_code <- PromoCodeGenerator.generate_promo_code(generator_opts),
                pickup_location <- LocationGenerator.generate_location(),
                destination_location <-
                  LocationGenerator.generate_promo_location(promo_code, location_opts) do
        refute Validator.valid?(promo_code, pickup_location, destination_location)
      end
    end
  end
end

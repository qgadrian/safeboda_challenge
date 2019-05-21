defmodule SafeBoda.PromoCodeStoreTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use SafeBoda.PromoCodeStore.Suppport.RepoCase

  doctest SafeBoda.PromoCodeStore

  alias SafeBoda.PromoCode.Generator.PromoCode, as: PromoCodeGenerator
  alias SafeBoda.PromoCodeStore
  alias SafeBoda.PromoCodeStore.Location
  alias SafeBoda.PromoCodeStore.Schema.PromoCode

  describe "Given promo code params" do
    test "when they are valid then new/1 returns a changeset with the persisted data" do
      generator_opts = [max_number_of_rides: 10, minimum_event_radius: 1000]

      check all promo_code <- PromoCodeGenerator.generate_promo_code(generator_opts) do
        params = Map.from_struct(promo_code)

        assert {:ok, changeset} = PromoCodeStore.new(params)

        expected_promo_code = %{promo_code | id: changeset.id, __meta__: nil}

        assert %{changeset | __meta__: nil} == expected_promo_code
      end
    end

    test "when they are invalid then new/1 returns a changeset with the errors" do
      assert {:error, changeset} = PromoCodeStore.new(%{})
      refute Enum.empty?(changeset.errors)
    end
  end

  describe "new/1" do
    test "creates a new promo code" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:code, "TESTNEW")

      assert {:ok, _promo_code} = PromoCodeStore.new(params)
    end

    test "failes if the code is already taken" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:code, "TESTNEW")

      assert {:ok, _promo_code} = PromoCodeStore.new(params)
      assert {:error, _promo_code} = PromoCodeStore.new(params)
    end
  end

  describe "update/1" do
    test "updates the promo code" do
      code = "UPDATETEST"

      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, false)
        |> Map.put(:code, code)

      assert {:ok, _promo_code} = PromoCodeStore.new(params)
      assert {:ok, promo_code} = PromoCodeStore.get(code)
      refute promo_code.active?

      update_changeset = PromoCode.changeset(promo_code, %{active?: true})
      assert {:ok, _promo_code} = PromoCodeStore.update(update_changeset)
      assert {:ok, promo_code} = PromoCodeStore.get(code)
      assert promo_code.active?
    end
  end

  describe "all/0" do
    test "returns an empty list when there are no promo codes" do
      assert PromoCodeStore.all() == []
    end

    test "returns an list with promo codes" do
      params = Map.from_struct(PromoCodeGenerator.valid_promo_code())

      assert length(PromoCodeStore.all()) == 0

      PromoCodeStore.new(%{params | code: "1"})
      PromoCodeStore.new(%{params | code: "2"})
      PromoCodeStore.new(%{params | code: "3"})
      PromoCodeStore.new(%{params | code: "4"})
      PromoCodeStore.new(%{params | code: "5"})

      assert length(PromoCodeStore.all()) == 5
    end
  end

  describe "all_active/0" do
    test "returns an empty list when there are no promo codes" do
      assert PromoCodeStore.all_active() == []
    end

    test "returns an list with promo codes" do
      active_params = Map.from_struct(PromoCodeGenerator.valid_promo_code())
      inactive_params = %{active_params | active?: false}

      assert length(PromoCodeStore.all_active()) == 0

      PromoCodeStore.new(%{active_params | code: "1"})
      PromoCodeStore.new(%{active_params | code: "2"})
      PromoCodeStore.new(%{active_params | code: "3"})

      PromoCodeStore.new(%{inactive_params | code: "4"})
      PromoCodeStore.new(%{inactive_params | code: "5"})

      assert length(PromoCodeStore.all()) == 5
      assert length(PromoCodeStore.all_active()) == 0
    end
  end

  describe "get/1" do
    test "returns an error if the code was not found" do
      assert PromoCodeStore.get("asdasd") == {:error, :not_found}
    end

    test "returns the promo code if it is found" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:code, "PROMOTEST")

      assert PromoCodeStore.get("PROMOTEST") == {:error, :not_found}

      {:ok, promo_code} = PromoCodeStore.new(params)

      assert PromoCodeStore.get("PROMOTEST") == {:ok, promo_code}
    end
  end

  describe "update_radius/2" do
    test "updates the radius of the promo code" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:minimum_event_radius, 500)

      {:ok, promo_code} = PromoCodeStore.new(params)
      assert promo_code.minimum_event_radius == 500
      {:ok, promo_code} = PromoCodeStore.update_radius(promo_code, 5000)
      assert promo_code.minimum_event_radius == 5000
    end
  end

  describe "desactive/1" do
    test "updates a promo code as not active" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, true)

      {:ok, promo_code} = PromoCodeStore.new(params)
      assert promo_code.active?
      {:ok, promo_code} = PromoCodeStore.desactive(promo_code)
      refute promo_code.active?
    end
  end

  describe "active/1" do
    test "updates a promo code as active" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, false)

      {:ok, promo_code} = PromoCodeStore.new(params)
      refute promo_code.active?
      {:ok, promo_code} = PromoCodeStore.active(promo_code)
      assert promo_code.active?
    end
  end

  describe "polyline/2" do
    test "returns an encoded polyline" do
      pickup_point = %Location{latitude: 150, longitude: 23}
      destination_point = %Location{latitude: 5, longitude: 7}
      assert "_ekkC_{or[~~s`B~h_tZ" == PromoCodeStore.polyline(pickup_point, destination_point)
    end
  end

  describe "validate/1" do
    test "returns an error if the code is not valid" do
      code = "VALIDATETEST"

      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, false)
        |> Map.put(:code, code)

      PromoCodeStore.new(params)

      pickup = %Location{latitude: 5, longitude: 7}
      destination = %Location{latitude: 53, longitude: 71}

      assert(PromoCodeStore.validate(code, pickup, destination) == {:error, :not_valid})
    end

    test "returns the promo with a polyline if it is valid" do
      code = "VALIDATETEST"

      expiration_date = DateTime.add(DateTime.utc_now(), 3600, :second)

      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, true)
        |> Map.put(:expiration_date, expiration_date)
        |> Map.put(:code, code)

      {:ok, promo_code} = PromoCodeStore.new(params)

      pickup = %Location{
        latitude: promo_code.event_latitude,
        longitude: promo_code.event_longitude
      }

      destination = %Location{
        latitude: promo_code.event_latitude,
        longitude: promo_code.event_longitude
      }

      assert {:ok, validated_promo_code} = PromoCodeStore.validate(code, pickup, destination)
      assert validated_promo_code.polyline != nil
      assert validated_promo_code == %{promo_code | polyline: validated_promo_code.polyline}
    end
  end
end

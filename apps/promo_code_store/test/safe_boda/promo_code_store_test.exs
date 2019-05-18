defmodule SafeBoda.PromoCodeStoreTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use SafeBoda.PromoCodeStore.Suppport.RepoCase

  doctest SafeBoda.PromoCodeStore

  alias SafeBoda.PromoCode.Generator.PromoCode, as: PromoCodeGenerator
  alias SafeBoda.PromoCodeStore

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

  describe "all/0" do
    test "returns an empty list when there are no promo codes" do
      assert PromoCodeStore.all() == []
    end

    test "returns an list with promo codes" do
      params = Map.from_struct(PromoCodeGenerator.valid_promo_code())

      assert length(PromoCodeStore.all()) == 0

      PromoCodeStore.new(params)
      PromoCodeStore.new(params)
      PromoCodeStore.new(params)
      PromoCodeStore.new(params)
      PromoCodeStore.new(params)

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

      PromoCodeStore.new(active_params)
      PromoCodeStore.new(active_params)
      PromoCodeStore.new(active_params)

      PromoCodeStore.new(inactive_params)
      PromoCodeStore.new(inactive_params)

      assert length(PromoCodeStore.all()) == 5
      assert length(PromoCodeStore.all_active()) == 0
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
end

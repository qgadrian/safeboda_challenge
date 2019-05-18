defmodule SafeBoda.PromoCodeModelTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use SafeBoda.PromoCodeModel.Suppport.RepoCase

  doctest SafeBoda.PromoCodeModel

  alias SafeBoda.PromoCode.Generator.PromoCode, as: PromoCodeGenerator
  alias SafeBoda.PromoCodeModel

  describe "Given promo code params" do
    test "when they are valid then new/1 returns a changeset with the persisted data" do
      generator_opts = [max_number_of_rides: 10]

      check all promo_code <- PromoCodeGenerator.generate_promo_code(generator_opts) do
        params = Map.from_struct(promo_code)

        assert {:ok, changeset} = PromoCodeModel.new(params)

        expected_promo_code = %{promo_code | id: changeset.id, __meta__: nil}

        assert %{changeset | __meta__: nil} == expected_promo_code
      end
    end

    test "when they are invalid then new/1 returns a changeset with the errors" do
      assert {:error, changeset} = PromoCodeModel.new(%{})
      refute Enum.empty?(changeset.errors)
    end
  end

  describe "all/0" do
    test "returns an empty list when there are no promo codes" do
      assert PromoCodeModel.all() == []
    end

    test "returns an list with promo codes" do
      params = Map.from_struct(PromoCodeGenerator.valid_promo_code())

      assert length(PromoCodeModel.all()) == 0

      PromoCodeModel.new(params)
      PromoCodeModel.new(params)
      PromoCodeModel.new(params)
      PromoCodeModel.new(params)
      PromoCodeModel.new(params)

      assert length(PromoCodeModel.all()) == 5
    end
  end

  describe "all_active/0" do
    test "returns an empty list when there are no promo codes" do
      assert PromoCodeModel.all_active() == []
    end

    test "returns an list with promo codes" do
      active_params = Map.from_struct(PromoCodeGenerator.valid_promo_code())
      inactive_params = %{active_params | active?: false}

      assert length(PromoCodeModel.all_active()) == 0

      PromoCodeModel.new(active_params)
      PromoCodeModel.new(active_params)
      PromoCodeModel.new(active_params)

      PromoCodeModel.new(inactive_params)
      PromoCodeModel.new(inactive_params)

      assert length(PromoCodeModel.all()) == 5
      assert length(PromoCodeModel.all_active()) == 0
    end
  end
end

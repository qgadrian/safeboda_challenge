defmodule SafeBoda.PromoCodeModelTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  doctest SafeBoda.PromoCodeModel

  alias SafeBoda.PromoCode.Generator.PromoCode, as: PromoCodeGenerator
  alias SafeBoda.PromoCodeModel

  describe "Given promo code params" do
    test "when they are valid then new/1 returns a changeset with the persisted data" do
      check all promo_code <- PromoCodeGenerator.generate_promo_code() do
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
end

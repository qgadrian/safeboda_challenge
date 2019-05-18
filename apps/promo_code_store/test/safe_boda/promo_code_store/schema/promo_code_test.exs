defmodule SafeBoda.PromoCodeStore.Schema.PromoCodeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  use SafeBoda.PromoCodeStore.Suppport.RepoCase

  doctest SafeBoda.PromoCodeStore.Schema.PromoCode

  alias SafeBoda.PromoCode.Generator.PromoCode, as: PromoCodeGenerator
  alias SafeBoda.PromoCodeStore.Schema.PromoCode

  property "changeset/2 returns a changeset with the parameters provided" do
    check all promo_code <- PromoCodeGenerator.generate_promo_code() do
      params = Map.from_struct(promo_code)

      changeset =
        %PromoCode{}
        |> PromoCode.changeset(params)
        |> Ecto.Changeset.apply_changes()

      assert promo_code == changeset
    end
  end

  describe "Given a promo code attributes" do
    test "when there are missing parameters then changeset/2 returns errors per required field" do
      params = %{}
      changeset = PromoCode.changeset(%PromoCode{}, params)
      assert Keyword.has_key?(changeset.errors, :expiration_date)
    end

    test "when all parameters are valid then changeset/2 returns errors per required field" do
      params = Map.from_struct(PromoCodeGenerator.valid_promo_code())
      changeset = PromoCode.changeset(%PromoCode{}, params)
      assert changeset.errors == []
    end
  end
end

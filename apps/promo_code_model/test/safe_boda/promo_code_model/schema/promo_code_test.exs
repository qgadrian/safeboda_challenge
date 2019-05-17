defmodule SafeBoda.PromoCodeModel.Schema.PromoCodeTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias SafeBoda.PromoCodeModel.Schema.PromoCode

  setup do
    Application.ensure_all_started(:stream_data)
  end

  property "changeset/2 returns a changeset with the parameters provided" do
    check all promo_code <- generate_promo_code() do
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
      params = %{expiration_date: DateTime.utc_now()}
      changeset = PromoCode.changeset(%PromoCode{}, params)
      assert changeset.errors == []
    end
  end

  def generate_promo_code() do
    gen all expiration_date <- gen_datetime(),
            description <- StreamData.string(:alphanumeric, min_length: 1),
            active? <- StreamData.boolean() do
      %PromoCode{
        active?: active?,
        expiration_date: expiration_date,
        description: description
      }
    end
  end

  # Date generators

  @time_zones ["Etc/UTC"]

  # def gen_date(:past) do
  ## TODO improve the data generation, it can create non existent dates
  # gen_date(1970..2399, 1..12, 1..31)
  # end

  @doc """
  Generates a date in the future
  """
  def gen_date() do
    %{year: year, month: month, day: day} = DateTime.utc_now()
    gen_date(year..2399, month..12, (day + 1)..31)
  end

  defp gen_date(year_range, month_range, day_range) do
    gen all year <- StreamData.integer(year_range),
            month <- StreamData.integer(month_range),
            day <- StreamData.integer(day_range),
            match?({:ok, _}, Date.from_erl({year, month, day})) do
      Date.from_erl!({year, month, day})
    end
  end

  defp gen_time do
    gen all hour <- StreamData.integer(0..23),
            minute <- StreamData.integer(0..59),
            second <- StreamData.integer(0..59) do
      Time.from_erl!({hour, minute, second})
    end
  end

  defp gen_naive_datetime do
    gen all date <- gen_date(),
            time <- gen_time() do
      {:ok, naive_datetime} = NaiveDateTime.new(date, time)
      naive_datetime
    end
  end

  defp gen_datetime do
    gen all naive_datetime <- gen_naive_datetime(),
            time_zone <- StreamData.member_of(@time_zones) do
      DateTime.from_naive!(naive_datetime, time_zone)
    end
  end
end

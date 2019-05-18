defmodule SafeBoda.PromoCode.Generator.DateTime do
  @moduledoc """
  Module that provides date and time generators to use with property based testing.
  """
  use ExUnitProperties

  @time_zones ["Etc/UTC"]

  @typep date_kind :: :future | :past | :any

  @doc """
  Generates a date in the future.

  This function accepts the following kind of dates `future`, `past` or `any`, defaults to `any`.
  """
  @spec gen_date(date_kind) :: StreamData.t(Date.t())
  def gen_date(kind \\ :any)

  def gen_date(:any) do
    gen_date(1970..2399, 1..12, 1..31)
  end

  def gen_date(:past) do
    %{year: year} = DateTime.utc_now()
    gen_date(1970..(year - 1), 1..12, 1..31)
  end

  def gen_date(:future) do
    %{year: year, month: month, day: day} = DateTime.utc_now()
    gen_date(year..2399, month..12, (day + 1)..31)
  end

  @doc """
  Generates a date time.
  """
  @spec gen_date(date_kind) :: StreamData.t(DateTime.t())
  def gen_datetime(kind \\ :any) do
    gen all naive_datetime <- gen_naive_datetime(kind),
            time_zone <- StreamData.member_of(@time_zones) do
      DateTime.from_naive!(naive_datetime, time_zone)
    end
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

  defp gen_naive_datetime(kind) do
    gen all date <- gen_date(kind),
            time <- gen_time() do
      {:ok, naive_datetime} = NaiveDateTime.new(date, time)
      naive_datetime
    end
  end
end

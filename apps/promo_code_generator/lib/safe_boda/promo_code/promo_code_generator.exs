defmodule SafeBoda.PromoCode.Generator.PromoCode do
  @moduledoc """
  Module that provides promo code generators to use with property based testing.
  """
  use ExUnitProperties

  alias SafeBoda.PromoCode.Generator.DateTime, as: DateTimeGenerator
  alias SafeBoda.PromoCodeStore.Schema.PromoCode

  @doc """
  Generates a promo code.

  The promo code will contain always a description and the active attribute
  will always be a boolean.

  ## Options:

  * `frequency_active`: Then frequency of when the promo code is active.
  * `frequency_expiration_future`: Then frequency of when the promo code is expired in the future.
  * `frequency_expiration_past`: Then frequency of when the promo code is expired in the past.
  * `frequency_inactive`: Then frequency of when the promo code is inactive.
  * `max_number_of_rides`: The maximum number of rides for the promo code, defaults to `999999`.
  * `max_event_radius`: The maximum radius from the promo code, defaults to `1000000`.
  * `min_event_radius`: The minimum radius from the promo code, defaults to `1000`.
  * `valid_code?`: Whether the code generated should be valid or not, defaults to `true`.
  """
  @spec generate_promo_code(keyword) :: StreamData.t(PromoCode.t())
  def generate_promo_code(opts \\ []) do
    frequency_active = Keyword.get(opts, :frequency_active, 1)
    frequency_expiration_future = Keyword.get(opts, :frequency_expiration_future, 1)
    frequency_expiration_past = Keyword.get(opts, :frequency_expiration_past, 1)
    frequency_inactive = Keyword.get(opts, :frequency_inactive, 1)
    max_number_of_rides = Keyword.get(opts, :max_number_of_rides, 999_999)
    max_event_radius = Keyword.get(opts, :max_event_radius, 1000)
    min_event_radius = Keyword.get(opts, :min_event_radius, 1_000_000)
    valid_code? = Keyword.get(opts, :valid_code?, true)

    gen all active? <- generate_active?(frequency_active, frequency_inactive),
            code <- generate_code(valid_code?),
            description <- StreamData.string(:alphanumeric, min_length: 1),
            event_latitude <- StreamData.float(min: -90, max: 90),
            event_longitude <- StreamData.float(min: -90, max: 90),
            expiration_date <-
              generate_expiration_date(frequency_expiration_future, frequency_expiration_past),
            minimum_event_radius <- StreamData.integer(min_event_radius..max_event_radius),
            number_of_rides <- StreamData.integer(1..max_number_of_rides) do
      %PromoCode{
        active?: active?,
        code: code,
        description: description,
        event_latitude: event_latitude,
        event_longitude: event_longitude,
        expiration_date: expiration_date,
        number_of_rides: number_of_rides,
        minimum_event_radius: minimum_event_radius
      }
    end
  end

  @doc """
  Generates a single valid promo code.

  Uses values by default for non required fields.

  This function returns a promo code struct and it cannot be used to generate
  properties.
  """
  @spec valid_promo_code() :: PromoCode.t()
  def valid_promo_code() do
    %PromoCode{
      expiration_date: DateTime.utc_now(),
      code: "PROMOCODE",
      event_latitude: 23.0,
      event_longitude: 7.0
    }
  end

  @spec generate_active?(pos_integer, pos_integer) :: StreamData.t(binary)
  defp generate_active?(freq_active, freq_inactive) do
    StreamData.frequency([
      {freq_active, StreamData.member_of([true])},
      {freq_inactive, StreamData.member_of([false])}
    ])
  end

  @spec generate_expiration_date(pos_integer, pos_integer) :: StreamData.t(binary)
  defp generate_expiration_date(freq_future, freq_past) do
    StreamData.frequency([
      {freq_future, DateTimeGenerator.gen_datetime(:future)},
      {freq_past, DateTimeGenerator.gen_datetime(:past)}
    ])
  end

  @spec generate_code(boolean) :: StreamData.t(binary)
  defp generate_code(valid?) do
    StreamData.filter(StreamData.string(:ascii, min_length: 1), fn code ->
      Regex.match?(~r/[A-Za-z0-9]+$/, code) == valid?
    end)
  end
end

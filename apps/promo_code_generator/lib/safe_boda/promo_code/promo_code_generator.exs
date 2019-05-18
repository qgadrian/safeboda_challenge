defmodule SafeBoda.PromoCode.Generator.PromoCode do
  @moduledoc """
  Module that provides promo code generators to use with property based testing.
  """
  use ExUnitProperties

  alias SafeBoda.PromoCode.Generator.DateTime, as: DateTimeGenerator
  alias SafeBoda.PromoCodeModel.Schema.PromoCode

  @doc """
  Generates a promo code.

  The promo code will contain always a description and the active attribute
  will always be a boolean.

  ## Options:

  * `max_number_of_rides`: The maximum number of rides for the promo code, defaults to `999999`.
  * `minimum_event_radius`: The minimum radius from the promo code, defaults to `10000`.
  """
  def generate_promo_code(opts \\ []) do
    max_number_of_rides = Keyword.get(opts, :max_number_of_rides, 999_999)
    minimum_event_radius = Keyword.get(opts, :minimum_event_radius, 999_999)

    gen all active? <- StreamData.boolean(),
            description <- StreamData.string(:alphanumeric, min_length: 1),
            expiration_date <- DateTimeGenerator.gen_datetime(),
            minimum_event_radius <- StreamData.integer(1..minimum_event_radius),
            number_of_rides <- StreamData.integer(1..max_number_of_rides) do
      %PromoCode{
        active?: active?,
        description: description,
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
      expiration_date: DateTime.utc_now()
    }
  end
end

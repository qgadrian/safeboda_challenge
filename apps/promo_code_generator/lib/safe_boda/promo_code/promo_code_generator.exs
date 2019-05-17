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
  """
  def generate_promo_code() do
    gen all expiration_date <- DateTimeGenerator.gen_datetime(),
            description <- StreamData.string(:alphanumeric, min_length: 1),
            active? <- StreamData.boolean() do
      %PromoCode{
        active?: active?,
        expiration_date: expiration_date,
        description: description
      }
    end
  end
end

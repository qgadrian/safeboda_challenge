defmodule SafeBoda.PromoCode.Generator.Location do
  @moduledoc """
  Generates location structs to be used in property based testing.
  """
  use ExUnitProperties

  alias SafeBoda.PromoCodeStore.Location

  @doc """
  Returns a generator for `t:#{Location}.t/0`.
  """
  def generate_location() do
    gen all latitude <- StreamData.float(),
            longitude <- StreamData.float() do
      %Location{latitude: latitude, longitude: longitude}
    end
  end
end

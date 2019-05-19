defmodule SafeBoda.PromoCodeStore.Location do
  @moduledoc """
  Represents a geographical location.
  """

  @typedoc """
  Represents a geographical location.
  """
  @type t :: %__MODULE__{
          latitude: float,
          longitude: float
        }

  @enforce_keys [
    :latitude,
    :longitude
  ]

  defstruct @enforce_keys

  @doc """
  Converts a location into a `t:Geocalc.Point.t/0`.

  ## Examples

      iex> location = %#{__MODULE__}{latitude: 23, longitude: 7}
      iex> #{__MODULE__}.geocalc_point(location)
      [23, 7]
  """
  @spec geocalc_point(__MODULE__.t()) :: Geocalc.Point.t()
  def geocalc_point(%__MODULE__{} = location) do
    [location.latitude, location.longitude]
  end
end

defmodule SafeBoda.PromoCodeStore.Schema.PromoCode do
  use Ecto.Schema

  @typedoc """
  A promo code.

  The promo code provides information about discounts in the SafeBoda application:

  * `active?`: If whether the promo code is active or not, defaults to `false`.
  * `code`: The code of the promo that user's will use within the clients. The
  code can contain number and letters only.
  * `description`: Description for the promo code, defaults to `nil`.
  * `expiration_date`: UTC date time from when the code can't be used anymore.
  This is a required field.
  * `number_of_rides`: The maximum number of times the promo code can be used, per user.
  * `minimum_event_radius`: The minimum radius from the event point where the
  promo code can be applicable, in meters.
  """
  @type t :: Ecto.Schema.t()

  # TODO This is a configuration parameter for a default value. It should be
  # provided by a environment variable that will be read at runtime, allowing
  # it to be dynamic at runtime.
  @max_number_of_rides 10
  @minimum_event_radius 1000

  @required_fields [
    :code,
    :event_latitude,
    :event_longitude,
    :expiration_date
  ]

  @optional_fields [
    :active?,
    :code,
    :description,
    :minimum_event_radius,
    :number_of_rides
  ]

  @fields @required_fields ++ @optional_fields

  schema "promo_codes" do
    field(:active?, :boolean, default: false)
    field(:code, :string)
    field(:description, :string, default: nil)
    field(:event_latitude, :float)
    field(:event_longitude, :float)
    field(:expiration_date, :utc_datetime)
    field(:minimum_event_radius, :integer, default: @minimum_event_radius)
    field(:number_of_rides, :integer, default: @max_number_of_rides)
  end

  @doc """
  Casts the given params a returns a `t:Ecto.Changeset.t/1` with the validation
  and changes.

  See `t:SafeBoda.PromoCodeStore.Schema.PromoCode.t/0` for the accepted fields.

  ## Examples

      iex> expiration_date = DateTime.from_unix!(1_464_096_368)
      iex> params = %{description: "SafeBodaPromo", event_latitude: 23, event_longitude: 7, code: "PROMOTEST", expiration_date: expiration_date}
      iex> changeset = #{__MODULE__}.changeset(%#{__MODULE__}{}, params)
      iex> true = changeset.valid?
      iex> Ecto.Changeset.apply_changes(changeset)
      %SafeBoda.PromoCodeStore.Schema.PromoCode{
        active?: false,
        code: "PROMOTEST",
        description: "SafeBodaPromo",
        event_latitude: 23.0,
        event_longitude: 7.0,
        expiration_date: DateTime.from_unix!(1_464_096_368),
        id: nil,
        minimum_event_radius: #{@minimum_event_radius},
        number_of_rides: #{@max_number_of_rides}
      }
  """
  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t(__MODULE__.t())
  def changeset(promo_code, params) do
    promo_code
    |> Ecto.Changeset.cast(params, @fields)
    |> Ecto.Changeset.validate_required(@required_fields)
    |> Ecto.Changeset.validate_format(:code, ~r/[A-Za-z0-9]+$/)
    |> Ecto.Changeset.validate_number(:number_of_rides,
      greater_than: 0,
      less_than_or_equal_to: @max_number_of_rides
    )
  end
end

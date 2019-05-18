defmodule SafeBoda.PromoCodeModel.Schema.PromoCode do
  use Ecto.Schema

  @typedoc """
  A promo code.

  The promo code provides information about discounts in the SafeBoda application:

  * `active?`: If whether the promo code is active or not, defaults to `false`.
  * `description`: Description for the promo code, defaults to `nil`.
  * `expiration_date`: UTC date time from when the code can't be used anymore.
  This is a required field.
  * `number_of_rides`: The maximum number of times the promo code can be used, per user.
  * `minimum_event_radius`: The minimum radius from the event point where the
  promo code can be applicable.
  """
  @type t :: Ecto.Schema.t()

  # TODO This is a configuration parameter. It should be provided by a
  # environment variable that will be read at runtime
  @max_number_of_rides 10
  @minimum_event_radius 1000

  @required_fields [:expiration_date]

  @optional_fields [
    :active?,
    :description,
    :minimum_event_radius,
    :number_of_rides
  ]

  @fields @required_fields ++ @optional_fields

  schema "promo_codes" do
    field(:active?, :boolean, default: false)
    field(:description, :string, default: nil)
    field(:expiration_date, :utc_datetime)
    field(:minimum_event_radius, :integer, default: @minimum_event_radius)
    field(:number_of_rides, :integer, default: @max_number_of_rides)
  end

  @doc """
  Casts the given params a returns a `t:Ecto.Changeset.t/1` with the validation
  and changes.

  See `t:SafeBoda.PromoCodeModel.Schema.PromoCode.t/0` for the accepted fields.

  ## Examples

      iex> expiration_date = DateTime.from_unix!(1_464_096_368)
      iex> params = %{description: "SafeBodaPromo", active: true, expiration_date: expiration_date}
      iex> changeset = #{__MODULE__}.changeset(%#{__MODULE__}{}, params)
      iex> true = changeset.valid?
      iex> Ecto.Changeset.apply_changes(changeset)
      %SafeBoda.PromoCodeModel.Schema.PromoCode{
        active?: false,
        description: "SafeBodaPromo",
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
    |> Ecto.Changeset.validate_number(:number_of_rides,
      greater_than: 0,
      less_than_or_equal_to: @max_number_of_rides
    )
    |> Ecto.Changeset.validate_required(@required_fields)
  end
end

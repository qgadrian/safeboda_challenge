defmodule SafeBoda.PromoCodeModel.Schema.PromoCode do
  use Ecto.Schema

  @typedoc """
  A promo code.

  The promo code provides information about discounts in the SafeBoda application:

  * `description`: Description for the promo code, defaults to `nil`.
  * `active?`: If whether the promo code is active or not, defaults to `false`.
  * `expiration_date`: UTC date time from when the code can't be used anymore. This is a required field.
  """
  @type t :: Ecto.Schema.t()

  @required_fields [:expiration_date]

  @optional_fields [:description, :active?]

  @fields @required_fields ++ @optional_fields

  schema "promo_codes" do
    field(:description, :string, default: nil)
    field(:active?, :boolean, default: false)
    field(:expiration_date, :utc_datetime)
  end

  @doc """
  Casts the given params a returns a `t:Ecto.Changeset.t/1` with the validation and changes.

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
              id: nil
            }
  """
  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t(__MODULE__.t())
  def changeset(promo_code, params \\ %{}) do
    promo_code
    |> Ecto.Changeset.cast(params, @fields)
    |> Ecto.Changeset.validate_required(@required_fields)
  end
end

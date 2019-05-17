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

  @spec changeset(__MODULE__.t(), map) :: Ecto.Changeset.t(__MODULE__.t())
  def changeset(promo_code, params \\ %{}) do
    promo_code
    |> Ecto.Changeset.cast(params, @fields)
    |> Ecto.Changeset.validate_required(@required_fields)
  end
end

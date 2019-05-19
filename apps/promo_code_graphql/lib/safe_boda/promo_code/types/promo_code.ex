defmodule SafeBoda.PromoCode.Graphql.Types.PromoCode do
  @moduledoc """
  Provides the GraphQL objects for promotional codes.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  @desc "A promotional code"
  object :promo_code do
    field(:active?, non_null(:boolean),
      name: "active",
      description: "Whether the promo code is flagged as active."
    )

    field(:code, non_null(:integer),
      description: "The maximum number of rides per user this promo code can be used in."
    )

    field(:description, :string, description: "The description of the promo code.")
    field(:event_latitude, non_null(:float), description: "The latitude of the event location.")
    field(:event_longitude, non_null(:float), description: "The longitude of the event location.")

    field(:expiration_date, non_null(:datetime),
      description:
        "The date (ISO8601 format) the promo code will expire and won't be applicable anymore."
    )

    field(:minimum_event_radius, non_null(:integer),
      description:
        "The minimum radius from the promo event location as a center point, where pickup or the destination should be inside."
    )

    field(:number_of_rides, non_null(:boolean),
      description: "Whether the promo code is flagged as active."
    )
  end

  @desc "A validated promotional code"
  object :promo_code_validation do
    import_fields(:promo_code)
    field(:polyline, :string)
  end
end

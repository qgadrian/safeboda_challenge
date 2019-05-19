defmodule SafeBoda.PromoCode.Graphql.Queries.PromoCode do
  @moduledoc """
  Provides the [GraphQL queries](https://graphql.org/learn/queries/) for promo
  codes.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias SafeBoda.PromoCode.Graphql.Resolvers.PromoCode, as: PromoCodeResolver

  @desc "Promo code queries"
  object :promo_code_queries do
    @desc "Get all promotional codes"
    field(:all_promo_codes, list_of(non_null(:promo_code))) do
      resolve(&PromoCodeResolver.all/2)
    end

    @desc "Get all active promotional codes"
    field(:all_active_promo_codes, list_of(non_null(:promo_code))) do
      resolve(&PromoCodeResolver.all_active/2)
    end

    @desc "Validates a promo code and a trip"
    field(:validate_promo_code, :promo_code_validation) do
      arg(:code, non_null(:string))
      arg(:destination_latitude, non_null(:float))
      arg(:destination_longitude, non_null(:float))
      arg(:pickup_latitude, non_null(:float))
      arg(:pickup_longitude, non_null(:float))

      resolve(&PromoCodeResolver.validate/2)
    end
  end
end

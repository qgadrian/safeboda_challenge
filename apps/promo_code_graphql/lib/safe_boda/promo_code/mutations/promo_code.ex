defmodule SafeBoda.PromoCode.Graphql.Mutations.PromoCode do
  @moduledoc """
  Provides [GraphQL mutations](https://graphql.org/learn/queries/#mutations) function for promo codes.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias SafeBoda.PromoCode.Graphql.Resolvers.PromoCode, as: PromoCodeResolver

  @desc "Promo code mutations"
  object :promo_code_mutations do
    @desc "Creates a promo code"
    field :create_promo_code, :promo_code do
      arg(:active, :boolean)
      arg(:code, non_null(:string))
      arg(:description, :string)
      arg(:event_latitude, non_null(:float))
      arg(:event_longitude, non_null(:float))
      arg(:expiration_date, non_null(:datetime))
      arg(:minimum_event_radius, :integer)
      arg(:number_of_rides, :integer)

      resolve(&PromoCodeResolver.create/2)
    end

    @desc "Change the active status of a promo code"
    field :update_promo_code_activation, :promo_code do
      arg(:active, non_null(:boolean))
      arg(:code, non_null(:string))

      resolve(&PromoCodeResolver.update_active/2)
    end

    @desc "Change the minimum radius of a promo code from where it can be used, in meters"
    field :update_promo_code_radius, :promo_code do
      arg(:radius, non_null(:integer))
      arg(:code, non_null(:string))

      resolve(&PromoCodeResolver.update_radius/2)
    end
  end
end

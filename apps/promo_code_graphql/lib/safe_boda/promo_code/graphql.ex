defmodule SafeBoda.PromoCode.Graphql do
  @moduledoc """
  Module that provides the GraphQL schema.

  The [GraphQL schema](https://graphql.org/learn/schema/) defined here contains
  the queries and the available types in the GraphQL server.
  """

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types(Absinthe.Type.Custom)

  import_types(SafeBoda.PromoCode.Graphql.Types.PromoCode)
  import_types(SafeBoda.PromoCode.Graphql.Queries.PromoCode)
  import_types(SafeBoda.PromoCode.Graphql.Mutations.PromoCode)

  query do
    import_fields(:promo_code_queries)
  end

  mutation do
    import_fields(:promo_code_mutations)
  end
end

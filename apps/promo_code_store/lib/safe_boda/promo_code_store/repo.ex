defmodule SafeBoda.PromoCodeStore.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :promo_code_store,
    adapter: Ecto.Adapters.Postgres
end

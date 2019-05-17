defmodule SafeBoda.PromoCodeModel.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :promo_code_model,
    adapter: Ecto.Adapters.Postgres
end

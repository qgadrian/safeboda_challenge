defmodule SafeBoda.PromoCodeStore.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :promo_code_store,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    new_config =
      config
      |> Keyword.put(:hostname, System.get_env("DB_URL") || config[:hostname])
      |> Keyword.put(:username, System.get_env("DB_USER") || config[:username])
      |> Keyword.put(:password, System.get_env("DB_PASS") || config[:password])
      |> Keyword.put(:port, System.get_env("DB_PORT") || config[:port])

    {:ok, new_config}
  end
end

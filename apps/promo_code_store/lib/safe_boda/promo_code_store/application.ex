defmodule SafeBoda.PromoCodeStore.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SafeBoda.PromoCodeStore.Repo
    ]

    opts = [strategy: :one_for_one, name: SafeBoda.PromoCodeStore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

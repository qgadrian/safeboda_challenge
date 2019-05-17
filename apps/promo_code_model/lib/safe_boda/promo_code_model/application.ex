defmodule SafeBoda.PromoCodeModel.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SafeBoda.PromoCodeModel.Repo
    ]

    opts = [strategy: :one_for_one, name: SafeBoda.PromoCodeModel.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

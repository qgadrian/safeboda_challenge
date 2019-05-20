defmodule SafeBoda.PromoCodeWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SafeBoda.PromoCodeWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: SafeBoda.PromoCodeWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SafeBoda.PromoCodeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

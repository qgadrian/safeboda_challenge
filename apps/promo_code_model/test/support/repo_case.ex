defmodule SafeBoda.PromoCodeModel.Suppport.RepoCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SafeBoda.PromoCodeModel.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SafeBoda.PromoCodeModel.Repo, {:shared, self()})
    end

    :ok
  end
end

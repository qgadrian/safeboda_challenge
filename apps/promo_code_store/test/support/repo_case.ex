defmodule SafeBoda.PromoCodeStore.Suppport.RepoCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SafeBoda.PromoCodeStore.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(SafeBoda.PromoCodeStore.Repo, {:shared, self()})
    end

    :ok
  end
end

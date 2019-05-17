defmodule SafeBoda.PromoCodeModel do
  @moduledoc """
  This module provides functions to interact with the promo code data persisted in the database.
  """

  alias SafeBoda.PromoCodeModel.Repo
  alias SafeBoda.PromoCodeModel.Schema.PromoCode

  @doc """
  Creates a new promo code.
  """
  @spec new(map) :: {:ok, PromoCode.t()} | {:error, term}
  def new(params) do
    %PromoCode{}
    |> PromoCode.changeset(params)
    |> Repo.insert()
  end

  @spec all() :: list(PromoCode.t())
  def all() do
    Repo.all(PromoCode)
  end
end

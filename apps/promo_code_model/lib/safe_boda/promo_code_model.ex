defmodule SafeBoda.PromoCodeModel do
  @moduledoc """
  This module provides functions to interact with the promo code data persisted in the database.
  """

  import Ecto.Query

  alias SafeBoda.PromoCodeModel.Repo
  alias SafeBoda.PromoCodeModel.Schema.PromoCode

  @doc """
  Creates a new promo code.

  If the creation success this function returns a tuple with the
  `t:PromoCode.t/0` containing the database id. Otherwise, this function
  returns a tuple with an error.

  ## Examples

      iex> expiration_date = DateTime.from_unix!(1_464_096_368)
      iex> params = %{description: "SafeBodaPromo", active: true, number_of_rides: 5, expiration_date: expiration_date}
      iex> {result, _promo_code} = #{__MODULE__}.new(params)
      iex> result
      :ok
  """
  @spec new(map) :: {:ok, PromoCode.t()} | {:error, term}
  def new(params) do
    %PromoCode{}
    |> PromoCode.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Returns all the promo codes.
  """
  @spec all() :: list(PromoCode.t())
  def all() do
    Repo.all(PromoCode)
  end

  @doc """
  Returns all the promo codes that are active.
  """
  @spec all_active() :: list(PromoCode.t())
  def all_active() do
    query = from(promo_code in PromoCode, select: promo_code, where: promo_code.active? == true)
    Repo.all(query)
    # []
  end
end

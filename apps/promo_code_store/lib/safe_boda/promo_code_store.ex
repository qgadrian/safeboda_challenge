defmodule SafeBoda.PromoCodeStore do
  @moduledoc """
  This module provides functions to interact with the promo code data persisted in the database.
  """

  import Ecto.Query

  require Logger

  alias SafeBoda.PromoCodeStore.Location
  alias SafeBoda.PromoCodeStore.Repo
  alias SafeBoda.PromoCodeStore.Schema.PromoCode
  alias SafeBoda.PromoCodeStore.Validator

  @typedoc """
  A line that has multiple points.

  The
  [polyline](https://developers.google.com/maps/documentation/javascript/examples/polyline-simple)
  encodes in a string multiple endpoints that draw a line.
  """
  @type polyline :: binary

  @doc """
  Creates a new promo code.

  If the creation success this function returns a tuple with the
  `t:PromoCode.t/0` containing the database id. Otherwise, this function
  returns a tuple with an error.

  ## Examples

      iex> expiration_date = DateTime.from_unix!(1_464_096_368)
      iex> params = %{code: "PROMOCODE", description: "SafeBodaPromo", event_latitude: 23.0, event_longitude: 5.0, active: true, number_of_rides: 5, expiration_date: expiration_date}
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
  Updates a promo code.

  If the update success, this function returns a tuple with the updated
  `t:PromoCode.t/0`. Otherwise, this function returns a tuple with an error.
  """
  @spec update(PromoCode.t()) :: {:ok, PromoCode.t()} | {:error, term}
  def update(promo_code) do
    IO.inspect(promo_code)
    Repo.update(promo_code)
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
    ## TODO missing expired validation
    query = from(promo_code in PromoCode, select: promo_code, where: promo_code.active? == true)
    Repo.all(query)
  end

  @doc """
  Returns the promo code from the code the user's use in the clients.
  """
  @spec get(String.t()) :: {:ok, PromoCode.t()} | {:error, :not_found}
  def get(code) do
    case Repo.get_by(PromoCode, code: code) do
      nil -> {:error, :not_found}
      promo_code -> {:ok, promo_code}
    end
  end

  @doc """
  Updates the promo code radius.

  The radius should be given in meters.
  """
  @spec update_radius(PromoCode.t(), non_neg_integer) :: {:ok, PromoCode.t()} | {:error, term}
  def update_radius(%PromoCode{} = promo_code, new_radius) do
    promo_code
    |> PromoCode.changeset(%{minimum_event_radius: new_radius})
    |> Repo.update()
  end

  @doc """
  Sets a promo code as inactive.

  Once a promo code is inactive, it cannot be used anymore.
  """
  @spec desactive(PromoCode.t()) :: {:ok, PromoCode.t()} | {:error, term}
  def desactive(%PromoCode{} = promo_code) do
    promo_code
    |> PromoCode.changeset(%{active?: false})
    |> Repo.update()
  end

  @doc """
  Sets a promo code as active.

  Once a promo code is active, it can be candidate to be used in user rides.
  """
  @spec active(PromoCode.t()) :: {:ok, PromoCode.t()} | {:error, term}
  def active(%PromoCode{} = promo_code) do
    promo_code
    |> PromoCode.changeset(%{active?: true})
    |> Repo.update()
  end

  @doc """
  Generates a polyline from two points.

  ## Example

      iex> pickup = %#{Location}{latitude: -120.2, longitude: 38.5}
      iex> destination = %#{Location}{latitude: -120.84, longitude: 78.5}
      iex> #{__MODULE__}.polyline(pickup, destination)
      "_p~iF~ps|U_ocsF~~{B"
  """
  @spec polyline(Location.t(), Location.t()) :: {:ok, String.t()} | {:error, :not_valid}
  def polyline(%Location{} = pickup, %Location{} = destination) do
    pickup_point = {pickup.latitude, pickup.longitude}
    destination_point = {destination.latitude, destination.longitude}

    Polyline.encode([pickup_point, destination_point])
  end

  @doc """
  Validates a promo code.

  Receives the string code of the promotion, a pickup and a destination location.

  If the promo code meets the requirements for the pickup and destination, this
  function returns a `t:polyline/0`.  Otherwise turns an error.
  """
  # TODO: avoid using a map and setup the struct for the response
  @spec validate(String.t(), Location.t(), Location.t()) ::
          {:ok, map} | {:error, :not_valid}
  def validate(code, %Location{} = pickup, %Location{} = destination) do
    with {:ok, promo_code} <- get(code),
         true <- Validator.valid?(promo_code, pickup, destination) do
      {:ok, %{promo_code | polyline: polyline(pickup, destination)}}
    else
      false ->
        Logger.debug(
          "Promo code not valid: #{inspect(code)} - pickup: #{inspect(pickup)} - destination: #{
            inspect(destination)
          }"
        )

        {:error, :not_valid}

      {:error, :not_found} = error ->
        Logger.debug("Promo code not found")
        error
    end
  end
end

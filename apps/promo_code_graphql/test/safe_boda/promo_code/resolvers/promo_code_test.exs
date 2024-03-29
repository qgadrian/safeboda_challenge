defmodule SafeBoda.PromoCode.Graphql.Resolvers.PromoCodeTest do
  use ExUnit.Case, async: true
  use SafeBoda.PromoCodeStore.Suppport.RepoCase

  alias SafeBoda.PromoCode.Generator.PromoCode, as: PromoCodeGenerator
  alias SafeBoda.PromoCodeStore
  alias SafeBoda.PromoCodeStore.Schema.PromoCode

  @promo_code_fields """
    code
    active
    description
    eventLatitude
    eventLongitude
    expirationDate
    minimumEventRadius
    numberOfRides
  """

  describe "Given a query for all promo codes" do
    test "it returns all the promo codes" do
      query = "{ allPromoCodes { #{@promo_code_fields} } }"

      params = Map.from_struct(PromoCodeGenerator.valid_promo_code())

      PromoCodeStore.new(%{params | code: "1"})
      PromoCodeStore.new(%{params | code: "2"})
      PromoCodeStore.new(%{params | code: "3"})
      PromoCodeStore.new(%{params | code: "4"})
      PromoCodeStore.new(%{params | code: "5"})

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)

      assert {:ok, %{data: %{"allPromoCodes" => promo_codes}}} = result
      assert length(promo_codes) == 5
    end

    test "when the are not results then an empty list is returned" do
      query = "{ allPromoCodes { #{@promo_code_fields} } }"

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)

      assert {:ok, %{data: %{"allPromoCodes" => []}}} = result
    end
  end

  describe "Given a query for all active promo codes" do
    test "it returns all the active promo codes" do
      query = "{ allActivePromoCodes { #{@promo_code_fields} } }"

      active_params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, true)

      inactive_params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, false)

      PromoCodeStore.new(%{active_params | code: "1"})
      PromoCodeStore.new(%{inactive_params | code: "2"})
      PromoCodeStore.new(%{inactive_params | code: "3"})
      PromoCodeStore.new(%{active_params | code: "4"})
      PromoCodeStore.new(%{active_params | code: "5"})

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)

      assert {:ok, %{data: %{"allActivePromoCodes" => promo_codes}}} = result
      assert length(promo_codes) == 3
      assert Enum.all?(promo_codes, & &1["active"])
    end

    test "when the are not results then an empty list is returned" do
      query = "{ allActivePromoCodes { #{@promo_code_fields} } }"

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)

      assert {:ok, %{data: %{"allActivePromoCodes" => []}}} = result
    end
  end

  describe "Given a promo code validation query" do
    test "when it is invalid then an error is returned" do
      code = "VALIDATETEST"

      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, false)
        |> Map.put(:code, code)

      {:ok, promo_code} = PromoCodeStore.new(params)

      query = """
        { validatePromoCode(code: \"#{code}\", pickupLatitude: #{promo_code.event_latitude}, pickupLongitude: #{
        promo_code.event_longitude
      }, destinationLatitude: #{promo_code.event_latitude}, destinationLongitude: #{
        promo_code.event_longitude
      }) { #{@promo_code_fields} polyline } }
      """

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)

      assert {:ok, %{data: %{"validatePromoCode" => nil}, errors: [%{message: "not_valid"}]}} =
               result
    end

    test "when it is valid then the promo code with the polyline is returned" do
      code = "VALIDATETEST"

      expiration_date = DateTime.add(DateTime.utc_now(), 3600, :second)

      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.from_struct()
        |> Map.put(:active?, true)
        |> Map.put(:expiration_date, expiration_date)
        |> Map.put(:code, code)

      {:ok, promo_code} = PromoCodeStore.new(params)

      query = """
        { validatePromoCode(code: \"#{code}\", pickupLatitude: #{promo_code.event_latitude}, pickupLongitude: #{
        promo_code.event_longitude
      }, destinationLatitude: #{promo_code.event_latitude}, destinationLongitude: #{
        promo_code.event_longitude
      }) { #{@promo_code_fields} polyline } }
      """

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)

      assert {:ok, %{data: %{"validatePromoCode" => promo_code}}} = result
      assert promo_code["polyline"] != nil
    end
  end

  describe "Given a create promo code mutation" do
    test "a promo code is returned when is created" do
      expected_promo_code = PromoCodeGenerator.valid_promo_code()

      query = """
      mutation {
        createPromoCode(
          active: #{expected_promo_code.active?}
          code: \"#{expected_promo_code.code}\"
          description: \"#{expected_promo_code.description}\"
          eventLatitude: #{expected_promo_code.event_latitude}
          eventLongitude: #{expected_promo_code.event_longitude}
          expiration_date: \"#{DateTime.to_iso8601(expected_promo_code.expiration_date)}\"
          minimum_event_radius: #{expected_promo_code.minimum_event_radius}
          number_of_rides: #{expected_promo_code.number_of_rides}
        ) {
          #{@promo_code_fields}
        }
      }
      """

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)
      assert {:ok, %{data: %{"createPromoCode" => promo_code}}} = result

      promo_code_map =
        Map.new(promo_code, fn {key, value} ->
          key = key |> Macro.underscore() |> String.to_atom()

          value =
            case key do
              :expiration_date ->
                {:ok, date, _} = DateTime.from_iso8601(value)
                date

              _ ->
                value
            end

          {key, value}
        end)

      # TODO dropping expiration_date because of milliseconds. A delta should
      # be used to compare this dates
      assert PromoCode |> struct(promo_code_map) |> Map.delete(:expiration_date) ==
               Map.delete(expected_promo_code, :expiration_date)
    end
  end

  describe "Given a update active promo code mutation" do
    test "the promo code updates to inactive" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.put(:active?, true)
        |> Map.from_struct()

      {:ok, promo_code} = PromoCodeStore.new(params)

      query = """
      mutation {
        updatePromoCodeActivation(
          active: false,
          code: \"#{promo_code.code}\"
        ) {
          #{@promo_code_fields}
        }
      }
      """

      assert {:ok, promo_code} = PromoCodeStore.get(promo_code.code)
      assert promo_code.active?

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)
      assert {:ok, %{data: %{"updatePromoCodeActivation" => promo_code}}} = result
      refute promo_code["active"]
    end

    test "the promo code updates to active" do
      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.put(:active?, false)
        |> Map.from_struct()

      {:ok, promo_code} = PromoCodeStore.new(params)

      query = """
      mutation {
        updatePromoCodeActivation(
          active: true,
          code: \"#{promo_code.code}\"
        ) {
          #{@promo_code_fields}
        }
      }
      """

      assert {:ok, promo_code} = PromoCodeStore.get(promo_code.code)
      refute promo_code.active?

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)
      assert {:ok, %{data: %{"updatePromoCodeActivation" => promo_code}}} = result
      assert promo_code["active"]
    end
  end

  describe "Given a mutation for update promo code radius" do
    test "the promo code updates it minimum radius" do
      expected_radius = 23000

      params =
        PromoCodeGenerator.valid_promo_code()
        |> Map.put(:active?, true)
        |> Map.from_struct()

      {:ok, promo_code} = PromoCodeStore.new(params)

      query = """
      mutation {
        updatePromoCodeRadius(
          radius: #{expected_radius},
          code: \"#{promo_code.code}\"
        ) {
          #{@promo_code_fields}
        }
      }
      """

      assert {:ok, promo_code} = PromoCodeStore.get(promo_code.code)
      assert promo_code.minimum_event_radius == params[:minimum_event_radius]

      result = Absinthe.run(query, SafeBoda.PromoCode.Graphql)
      assert {:ok, %{data: %{"updatePromoCodeRadius" => promo_code}}} = result
      assert promo_code["minimumEventRadius"] == expected_radius
    end
  end
end

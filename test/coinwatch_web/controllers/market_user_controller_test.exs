defmodule CoinwatchWeb.MarketUserControllerTest do
  use CoinwatchWeb.ConnCase

  alias Coinwatch.Relations
  alias Coinwatch.Accounts
  alias Coinwatch.Assets

  #attrs
  @user_attrs %{email: "some@email.com", password: "password", username: "username"}
  @market_attrs %{exchange: "exchange", pair: "pair"}
  @market_attrs1 %{exhchange: "exchange1", pair: "pair1"}


  # fixtures
  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  def fixture(:market) do
    {:ok, market} = Assets.create_market(@market_attrs)
    market
  end

  def fixture(:mu) do
    user = fixture(:user)
    market = fixture(:market)
    {:ok, mu} = Relations.create_market_user(%{user_id: user.id, market_id: market.id})
    mu
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "creates and renders a User by ids", %{conn: conn} do
      user = fixture(:user)
      market = fixture(:market)
      conn = post(conn, market_user_path(conn, :create, %{market_user: %{user_id: user.id, market_id: market.id}}))
      assert %{"id" => _id} = json_response(conn, 201)["data"]
      assert %{"username" => _username} = json_response(conn, 201)["data"]
      assert %{"markets" => _markets} = json_response(conn, 201)["data"]
    end

    test "creates many market_users and renders user", %{conn: conn} do
      user = fixture(:user)
      market = fixture(:market)

      conn = post(conn, market_user_path(conn, :create, %{user_id: user.id, markets: [market.id]}))
      assert %{"id" => _id} = json_response(conn, 201)["data"]
      assert %{"username" => _username} = json_response(conn, 201)["data"]
      assert %{"markets" => _markets} = json_response(conn, 201)["data"]
    end
  end


  describe "delete" do
    setup [:delete_setup]

    test "deletes MarketUser by ids", %{conn: conn, market_user: market_user} do
      conn = delete(conn, market_user_path(conn, :delete, %{market_user: market_user}))
      assert %{"id" => _id} = json_response(conn, 200)["data"]
      assert %{"username" => _username} = json_response(conn, 200)["data"]
      assert %{"markets" => markets} = json_response(conn, 200)["data"]

      filtered = Enum.reject(markets, fn market ->
        market.id == market_user[:user_id]
      end)
      assert Enum.count(markets) == Enum.count(filtered)
    end

    test "deletes many MarketUsers", %{conn: conn, user_id: user_id, markets: markets} do
      conn = delete(conn, market_user_path(conn, :delete, %{user_id: user_id, markets: markets}))
      assert %{"id" => _id} = json_response(conn, 200)["data"]
      assert %{"markets" => _markets} = json_response(conn, 200)["data"]
    end
  end

  defp delete_setup(_) do
    mu = fixture(:mu)
    {:ok, market_user: %{user_id: mu.user_id, market_id: mu.market_id},
          user_id: mu.user_id, markets: [mu.market_id]}
  end


end

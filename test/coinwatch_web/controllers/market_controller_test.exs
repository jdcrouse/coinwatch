defmodule CoinwatchWeb.MarketControllerTest do
  use CoinwatchWeb.ConnCase

  alias Coinwatch.Assets
  alias Coinwatch.Assets.Market

  @create_attrs %{exchange: "some exchange", pair: "some pair", rate: "120.5"}
  @update_attrs %{exchange: "some updated exchange", pair: "some updated pair", rate: "456.7"}
  @invalid_attrs %{exchange: nil, pair: nil, rate: nil}

  def fixture(:market) do
    {:ok, market} = Assets.create_market(@create_attrs)
    market
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all market", %{conn: conn} do
      conn = get conn, market_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create market" do
    test "renders market when data is valid", %{conn: conn} do
      conn = post conn, market_path(conn, :create), market: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, market_path(conn, :show, id)

      assert %{"id" => id} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, market_path(conn, :create), market: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update market" do
    setup [:create_market]

    test "renders market when data is valid", %{conn: conn, market: %Market{id: id} = market} do
      conn = put conn, market_path(conn, :update, market), market: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, market_path(conn, :show, id)
      assert %{"id" => id} = json_response(conn, 200)["data"]
      assert %{"exchange" => "some updated exchange"} = json_response(conn, 200)["data"]
      assert %{"pair" => "some updated pair"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, market: market} do
      conn = put conn, market_path(conn, :update, market), market: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete market" do
    setup [:create_market]

    test "deletes chosen market", %{conn: conn, market: market} do
      conn = delete conn, market_path(conn, :delete, market)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, market_path(conn, :show, market)
      end
    end
  end

  defp create_market(_) do
    market = fixture(:market)
    {:ok, market: market}
  end
end

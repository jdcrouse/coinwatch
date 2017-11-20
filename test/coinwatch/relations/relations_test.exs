defmodule Coinwatch.RelationsTest do
  use Coinwatch.DataCase

  alias Coinwatch.Relations
  alias Coinwatch.Accounts
  alias Coinwatch.Assets

  describe "market_users" do
    alias Coinwatch.Relations.MarketUser
    alias Coinwatch.Accounts.User
    alias Coinwatch.Assets.Market

    @valid_user_attrs %{email: "some@email.com", username: "username", password: "password"}
    @valid_market_attrs %{exchange: "exchange", pair: "pair"}
    @invalid_mu_attrs %{user_id: nil, market_id: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Accounts.create_user()

      user
    end

    def market_fixture(attrs \\ %{}) do
      {:ok, market} =
        attrs
        |> Enum.into(@valid_market_attrs)
        |> Assets.create_market()
      market
    end

    def mu_fixture(attrs \\ %{}) do
      user = user_fixture()
      market = market_fixture()

      {:ok, mu} =
        attrs
        |> Enum.into(%{user_id: user.id, market_id: market.id})
        |> Relations.create_market_user()
      mu
    end

    test "list_market_user/0 returns all market_users" do
      mu = mu_fixture()
      assert Relations.list_market_user() == [mu]
    end

    test "get_market_user!/1 returns a market_user with given id" do
      mu = mu_fixture()
      assert Relations.get_market_user!(mu.id) == mu
    end

    test "get_market_user!/2 returns a market_user with given user_id and market_id" do
      mu = mu_fixture()
      assert Relations.get_market_user!(mu.user_id, mu.market_id) == mu
    end

    test "create_market_user/1 with valid data creates a MarketUser" do
      user = user_fixture()
      market = market_fixture()
      assert {:ok, %MarketUser{} = _mu} = Relations.create_market_user(%{user_id: user.id, market_id: market.id})
    end

    test "create_market_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Relations.create_market_user(@invalid_mu_attrs)
    end

    test "delete_market_user/1 deletes the market_user" do
      mu = mu_fixture()
      assert {:ok, %MarketUser{}} = Relations.delete_market_user(mu)
      assert_raise Ecto.NoResultsError, fn -> Relations.get_market_user!(mu.id) end
    end

    test "deleting a user, deletes the market_user" do
      mu = mu_fixture()
      user = Accounts.get_user!(mu.user_id)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Relations.get_market_user!(mu.id) end
    end

    test "deleting a market, deletes the market_user" do
      mu = mu_fixture()
      market = Assets.get_market!(mu.market_id)
      assert {:ok, %Market{}} = Assets.delete_market(market)
      assert_raise Ecto.NoResultsError, fn -> Relations.get_market_user!(mu.id) end
    end
  end
end

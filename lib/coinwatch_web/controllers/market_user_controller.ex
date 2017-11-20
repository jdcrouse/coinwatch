defmodule CoinwatchWeb.MarketUserController do
  use CoinwatchWeb, :controller

  alias Coinwatch.Relations
  alias Coinwatch.Relations.MarketUser
  alias Coinwatch.Accounts

  #TODO ensure user is logged in?

  # user follows market, renders user.json
  def create(conn, %{"market_user" => params}) do
    with {:ok, %MarketUser{} = mu} <- Relations.create_market_user(params) do
      user = Accounts.get_user!(mu.user_id)
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def create(conn, %{"user_id" => user_id, "markets" => market_ids}) do
    with _mus <- Relations.create_all_market_user(user_id, market_ids) do
      user = Accounts.get_user!(user_id)
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def delete(conn, %{"market_user" => params}) do
    mu = Relations.get_market_user!(params)

    with {:ok, %MarketUser{}} <- Relations.delete_market_user(mu) do
      user = Accounts.get_user!(mu.user_id)

      conn
      |> put_status(:ok)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def delete(conn, %{"user_id" => user_id, "markets" => market_ids}) do
    with _mus <- Relations.delete_all_market_user(user_id, market_ids) do
      user = Accounts.get_user!(user_id)
      conn
      |> put_status(:ok)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

end

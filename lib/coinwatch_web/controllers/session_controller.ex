defmodule CoinwatchWeb.SessionController do
  use CoinwatchWeb, :controller
  @moduledoc false

  alias Coinwatch.Accounts.User
  alias Coinwatch.Repo

  # create a session jwt if user can be authenticated
  def create(conn, %{"username" => username, "password" => password}) do
    case authenticate(username, password) do
      {:ok, user} ->
        new_conn = Guardian.Plug.api_sign_in(conn, user, :access)
        jwt = Guardian.Plug.current_token(new_conn)
        new_conn
        |> put_status(:created)
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> render("show.json", %{user: user, jwt: jwt})

      :error ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json")
    end
  end

  def refresh(conn, _params \\ {}) do
    user = Guardian.Plug.current_resource(conn)
    jwt = Guardian.Plug.current_token(conn)

    IO.inspect(user)
    IO.inspect(jwt)
    {:ok, claims} = Guardian.Plug.claims(conn)

    case Guardian.refresh!(jwt, claims) do
      {:ok, new_jwt, _new_claims} ->
        conn
        |> put_status(:ok)
        |> render("show.json", %{user: user, jwt: new_jwt})

      _ ->
        conn
        |> put_status(:unauthorized)
        |> render("forbidden.json", error: "Not authenticated")
    end

  end

  def delete(conn, _params) do
    jwt = Guardian.Plug.current_token(conn)
    Guardian.revoke!(jwt)

    conn
    |> put_status(:ok)
    |> render("delete.json")
  end

  def cors(conn, _params) do
    conn
    |> put_status(:ok)
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> send_resp(:ok, "")
  end


  defp authenticate(username, password) do
    user = Repo.get_by(User, username: username)
    case check_password(user, password) do
      true -> {:ok, user}
      _ -> :error
    end
  end

  def check_password(nil, _) do
    Comeonin.Argon2.dummy_checkpw()
  end

  def check_password(user, password) do
    Comeonin.Argon2.checkpw(password, user.password_hash)
  end
end

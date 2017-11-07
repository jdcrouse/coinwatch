defmodule Coinwatch.Relations do
  @moduledoc """
  The Relations context. This contains join tables.
  """

  import Ecto.Query, warn: false
  alias Coinwatch.Repo
  alias Coinwatch.Relations.MarketUser


  @doc """
    Returns a list of MarketUser.
  """
  def list_market_user do
    Repo.all(MarketUser)
  end

  @doc """
    Retrieves a single MarketUser.
    Raises 'Ecto.NoResultsError' if the MarketUser does not exist.
  """
  def get_market_user!(%{"user_id" => user_id, "market_id" => market_id}) do
    Repo.one(from(m in MarketUser,
      where: m.user_id == ^user_id and m.market_id == ^market_id))

  end

  def get_market_user!(id), do: Repo.get!(MarketUser, id)

  @doc """
    Creates a MarketUser.
  """
  def create_market_user(attrs \\ %{}) do
    %MarketUser{}
    |> MarketUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
    Delete a MarketUser.
  """
  def delete_market_user(%MarketUser{} = market_user) do
    Repo.delete(market_user)
  end
end

defmodule Coinwatch.Assets do
  @moduledoc """
  The Assets context.
  """

  import Ecto.Query, warn: false
  alias Coinwatch.Repo

  alias Coinwatch.Assets.Market


  #Returns the current price for all supported markets in JSON.
  #Some values may be out of date by a few seconds.
  #### Data is in the form "EXCHANGE:PAIR" : PRICE in a list
  def market_prices_URL do
    "https://api.cryptowat.ch/markets/prices"
  end

  # Returns the market summary for all supported markets.
  # Some values may be out of date by a few seconds.
  def market_summary_URL do
    "https://api.cryptowat.ch/markets/summaries"
  end

  @doc """
  Returns the list of market.

  ## Examples

      iex> list_market()
      [%Market{}, ...]

  """
  def list_market do
    Repo.all(Market)
  end

  @doc """
  Gets a single market.

  Raises `Ecto.NoResultsError` if the Market does not exist.

  ## Examples

      iex> get_market!(123)
      %Market{}

      iex> get_market!(456)
      ** (Ecto.NoResultsError)

  """
  def get_market!(id), do: Repo.get!(Market, id)

  @doc """
  Creates a market.

  ## Examples

      iex> create_market(%{field: value})
      {:ok, %Market{}}

      iex> create_market(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_market(attrs \\ %{}) do
    %Market{}
    |> Market.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a market.

  ## Examples

      iex> update_market(market, %{field: new_value})
      {:ok, %Market{}}

      iex> update_market(market, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_market(%Market{} = market, attrs) do
    market
    |> Market.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Market.

  ## Examples

      iex> delete_market(market)
      {:ok, %Market{}}

      iex> delete_market(market)
      {:error, %Ecto.Changeset{}}

  """
  def delete_market(%Market{} = market) do
    Repo.delete(market)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking market changes.

  ## Examples

      iex> change_market(market)
      %Ecto.Changeset{source: %Market{}}

  """
  def change_market(%Market{} = market) do
    Market.changeset(market, %{})
  end

  def get_decoded_URL(url) do
    res = HTTPoison.get!(url)
    Poison.decode(res.body)
  end

  def isolate_result(res) do
    with {:ok, result} <- Map.fetch(res, "result") do
      result
    end
  end

  @doc """
    Gets all markets and their prices. For each obtained data,
    a Market struct is either created or updated to contain the latest
    price information.
  """
  def upsert_markets do
    with {:ok, map} <- get_decoded_URL(market_prices_URL()) do
      map
      |> isolate_result()
      |> Enum.each(fn {k, v} ->
          upsert_market(k, v)
        end)

      broadcast_markets()
    end
    process_notifs()
  end


  @doc """
    Updates or inserts a Market with the new rate.
  """
  def upsert_market(exchangepair, rate) do
    list = String.split(exchangepair, ":")
    exchange = List.first(list)
    pair = List.last(list)

    get_or_create(exchange, pair)
    |> Market.changeset(%{rate: rate})
    |> Repo.insert_or_update()
  end

  @doc """
    Retrieves an existing Market matching the exchange and pair arguments or
    creates a new one.
  """
  def get_or_create(exchange, pair) do
    case Repo.get_by(Market, exchange: exchange, pair: pair) do
      nil ->
        %Market{exchange: exchange, pair: pair}
      market ->
        market
    end
  end

  @doc """
    Broadcasts all market data in one blob to members of channel
    market_data:all
  """
  def broadcast_markets() do
    CoinwatchWeb.Endpoint.broadcast("market_data:all", "market_data", %{market_data: list_market()})
  end

  # from https://coderwall.com/p/fhsehq/fix-encoding-issue-with-ecto-and-poison
  # to fix Poison encoding error when encoding a struct
  # added :users in sanitize map (they are not preloaded)
  defimpl Poison.Encoder , for: Coinwatch.Assets.Market do
    def encode(%{__struct__: _} = struct, options) do
      map = struct
        |> Map.from_struct
        |> sanitize_map

      Poison.Encoder.Map.encode(map, options)
    end

    defp sanitize_map(map) do
      Map.drop(map, [:__meta__, :__struct__, :users])
    end
  end

  alias Coinwatch.Assets.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  def update_notification!(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Deletes a Notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{source: %Notification{}}

  """
  def change_notification(%Notification{} = notification) do
    Notification.changeset(notification, %{})
  end

  # handles sending notifications when necessary and deleting already notified
  # notifications
  def process_notifs() do
    notifs = list_notifications()

    for notif <- notifs do
      cond do
        # if notified, delete
        notif.notified -> delete_notification(notif)
        #otherwise, check if it has passed above (or below) desired val
        notif.high -> check_passed_above(notif)
        true -> check_passed_below(notif)
      end
    end
  end

  defp check_passed_above(notif) do
    # if previous value < threshold and current value > threshold,
      # - notify user
      # - mark as notified
    new_notif = update_most_recent_price_high(notif)
    new_rate = new_notif.last_rate

    if new_rate > Decimal.new(notif.threshold) do
      Coinwatch.Mailer.send_price_alert_email(new_notif)
      IO.puts("sent alert email")
      update_notification!(notif, %{notified: true})
    end
  end

  defp check_passed_below(notif) do
    # if previous value > threshold and current value < threshold,
      # - notify user
      # - mark as notified
      new_notif = update_most_recent_price_low(notif)
      new_rate = new_notif.last_rate

      IO.puts("new rate: " <> Decimal.to_string(new_rate))
      IO.puts("threshold: " <> Integer.to_string(notif.threshold))

      if new_rate < Decimal.new(notif.threshold) do
        Coinwatch.Mailer.send_price_alert_email(new_notif)
        IO.puts("sent alert email")
        update_notification!(notif, %{notified: true})
      end
  end

  # these next two and their helpers are almost identical and can definitely be
  # abstracted--need to make sure they work first
  defp update_most_recent_price_high(notif) do
    # get markets for a specific pair
    marks = get_markets_by_pair(notif.pair)
    high = find_highest_market_above(notif.last_rate, marks)
    update_notification!(notif, %{last_rate: high})
  end

  defp find_highest_market_above(rate, [head | tail]) do
    if head.rate > rate do
      find_highest_market_above(head.rate, tail)
    else
      find_highest_market_above(rate, tail)
    end
  end

  defp find_highest_market_above(rate, []) do
    rate
  end

  defp update_most_recent_price_low(notif) do
    # get markets for a specific pair
    marks = get_markets_by_pair(notif.pair)
    low = find_lowest_market_below(notif.last_rate, marks)
    update_notification!(notif, %{last_rate: low})
  end

  defp find_lowest_market_below(rate, [head | tail]) do
    if head.rate < rate do
      find_lowest_market_below(head.rate, tail)
    else
      find_lowest_market_below(rate, tail)
    end
  end

  defp find_lowest_market_below(rate, []) do
    rate
  end

  def get_markets_by_pair(pair) do
    Repo.all(from m in Market, where: m.pair == ^pair)
  end
end

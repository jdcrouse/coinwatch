defmodule CoinwatchWeb.MarketView do
  use CoinwatchWeb, :view
  alias CoinwatchWeb.MarketView

  def render("index.json", %{market: market}) do
    %{data: render_many(market, MarketView, "market.json")}
  end

  def render("show.json", %{market: market}) do
    %{data: render_one(market, MarketView, "market.json")}
  end

  def render("market.json", %{market: market}) do
    %{
      id: market.id,
      exchange: market.exchange,
      pair: market.pair,
      rate: market.rate,
      updated: market.updated_at,
      }
  end
end

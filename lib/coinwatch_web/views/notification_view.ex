defmodule CoinwatchWeb.NotificationView do
  use CoinwatchWeb, :view
  alias CoinwatchWeb.NotificationView

  def render("index.json", %{notifications: notifications}) do
    %{data: render_many(notifications, NotificationView, "notification.json")}
  end

  def render("show.json", %{notification: notification}) do
    %{data: render_one(notification, NotificationView, "notification.json")}
  end

  def render("notification.json", %{notification: notification}) do
    %{id: notification.id,
      pair: notification.pair,
      threshold: notification.threshold,
      high: notification.high,
      notified: notification.notified}
  end
end

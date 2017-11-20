defmodule CoinwatchWeb.NotificationController do
  use CoinwatchWeb, :controller

  alias Coinwatch.Assets
  alias Coinwatch.Assets.Notification
  alias Coinwatch.Mailer

  action_fallback CoinwatchWeb.FallbackController

  def index(conn, _params) do
    notifications = Assets.list_notifications()
    render(conn, "index.json", notifications: notifications)
  end

  def create(conn, %{"notification" => notification_params}) do
    with {:ok, %Notification{} = notification} <- Assets.create_notification(notification_params) do
      Mailer.send_signup_confirmation(notification)

      conn
      |> put_status(:created)
      |> put_resp_header("location", notification_path(conn, :show, notification))
      |> render("show.json", notification: notification)
    end
  end

  def show(conn, %{"id" => id}) do
    notification = Assets.get_notification!(id)
    render(conn, "show.json", notification: notification)
  end

  def update(conn, %{"id" => id, "notification" => notification_params}) do
    notification = Assets.get_notification!(id)

    with {:ok, %Notification{} = notification} <- Assets.update_notification(notification, notification_params) do
      render(conn, "show.json", notification: notification)
    end
  end

  def delete(conn, %{"id" => id}) do
    notification = Assets.get_notification!(id)
    with {:ok, %Notification{}} <- Assets.delete_notification(notification) do
      send_resp(conn, :no_content, "")
    end
  end
end

defmodule CoinwatchWeb.NotificationController do
  use CoinwatchWeb, :controller

  alias Coinwatch.Assets
  alias Coinwatch.Assets.Notification

  def index(conn, _params) do
    notifications = Assets.list_notifications()
    render(conn, "index.html", notifications: notifications)
  end

  def new(conn, _params) do
    changeset = Assets.change_notification(%Notification{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"notification" => notification_params}) do
    case Assets.create_notification(notification_params) do
      {:ok, notification} ->
        conn
        |> put_flash(:info, "Notification created successfully.")
        |> redirect(to: notification_path(conn, :show, notification))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    notification = Assets.get_notification!(id)
    render(conn, "show.html", notification: notification)
  end

  def edit(conn, %{"id" => id}) do
    notification = Assets.get_notification!(id)
    changeset = Assets.change_notification(notification)
    render(conn, "edit.html", notification: notification, changeset: changeset)
  end

  def update(conn, %{"id" => id, "notification" => notification_params}) do
    notification = Assets.get_notification!(id)

    case Assets.update_notification(notification, notification_params) do
      {:ok, notification} ->
        conn
        |> put_flash(:info, "Notification updated successfully.")
        |> redirect(to: notification_path(conn, :show, notification))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", notification: notification, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    notification = Assets.get_notification!(id)
    {:ok, _notification} = Assets.delete_notification(notification)

    conn
    |> put_flash(:info, "Notification deleted successfully.")
    |> redirect(to: notification_path(conn, :index))
  end
end

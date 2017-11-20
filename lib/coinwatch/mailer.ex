defmodule Coinwatch.Mailer do
  use Mailgun.Client,
      domain: Application.get_env(:coinwatch, :mailgun_domain),
      key: Application.get_env(:coinwatch, :mailgun_key)

  @from "coinwatch@mg.jdcrouse.org"

  def send_signup_confirmation(notif) do
    usr = Coinwatch.Accounts.get_user!(notif.user_id)
    addr = usr.email
    pair = notif.pair
    val = Integer.to_string(notif.threshold)
    above? = notif.high

    send_email to: addr,
               from: @from,
               subject: "Signup confirmation for " <> pair,
               text: signup_text(pair, val, above?)
  end

  def send_price_alert_email(notif) do
    usr = Coinwatch.Accounts.get_user!(notif.user_id)
    addr = usr.email
    pair = notif.pair
    val = Integer.to_string(notif.threshold)
    above? = notif.high

    send_email to: addr,
               from: @from,
               subject: "Price Alert for " <> pair,
               text: alert_text(pair, val, above?)
  end

  defp alert_text(curr, val, above?) do
    if above? do
      "The price for " <> curr <> " has gone above your desired alert value of $" <> val <> "."
    else
      "The price for " <> curr <> " has gone below your desired alert value of $" <> val <> "."
    end
  end

  defp signup_text(curr, val, above?) do
    if above? do
      "You have signed up to be notified when " <> curr <> " goes above $" <> val
    else
      "You have signed up to be notified when " <> curr <> " goes below $" <> val
    end
  end


end

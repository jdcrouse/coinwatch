# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Coinwatch.Repo.insert!(%Coinwatch.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Coinwatch.Repo
alias Coinwatch.Assets.Notification
alias Coinwatch.Accounts.User
Repo.delete_all(Notification)

#Coinwatch.Accounts.create_user(%{username: "jdcrouse", email: "jdcrouse21@gmail.com", password: "passworddd", password_confirmation: "passworddd"})
# jj = Coinwatch.Accounts.get_user!(3)
# Coinwatch.Assets.create_notification(%{user_id: jj.id, pair: "btcusd", threshold: 10000, high: false, notified: false, last_rate: 3})
#Repo.insert(%User{username: "jdcrouse", email: "jdcrouse21@gmail.com", password: "passworddd", password_confirmation: "passworddd"})
#Repo.insert(%Notification{user_id: 1, pair: "btcusd", threshold: 340, high: true, notified: false, last_rate: 3})
#Repo.insert(%Notification{pair: "btcusd", threshold: 10000, high: false, notified: false, last_rate: 100000})
#Repo.insert(%Notification{pair: "btcusd", threshold: 340, high: true, notified: true, last_rate: 3})

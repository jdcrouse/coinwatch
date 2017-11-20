# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :coinwatch,
  ecto_repos: [Coinwatch.Repo]

# Configures the endpoint
config :coinwatch, CoinwatchWeb.Endpoint,
  url: [host: "http://api.coinwatch.pelkey.tech"],
  secret_key_base: "QYoUqAtcq+if4NemZM6ra0e8TXKG7ExCF9MJUT5kjMieBBaCpedsGGgeCgvYB4ZX",
  render_errors: [view: CoinwatchWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Coinwatch.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  issuer: "Coinwatch",
  serializer: Coinwatch.GuardianSerializer,
  secret_key: "HHuQ//yJbyrNQQjLjo3c4wInp7wTOaMzekqZxypuVVsX6M4TncoFuP1RpNU/BtSk"

config :coinwatch, Coinwatch.Scheduler,
       jobs: [
         market_data: [
           schedule: {:extended, "*/20"}, # run every 20 seconds
           task: {Coinwatch.Assets, :upsert_markets, []}
         ]
       ]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
import_config "config.secret.exs"

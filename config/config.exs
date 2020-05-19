# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :leap,
  ecto_repos: [Leap.Repo]

# Configures the endpoint
config :leap, LeapWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "k+4P4FrpUGP8ZI0kl/XHVpjY+7SmKJfKwv+h7b+aeg4X1TfMXSf/PDDTyAIuCFw3",
  render_errors: [view: LeapWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Leap.PubSub,
  live_view: [signing_salt: "W95YXk9p"]

# for dev providers are added in dev.secret.exs
config :leap, :pow_assent, http_adapter: Assent.HTTPAdapter.Mint

config :pow, Pow.Postgres.Store,
  repo: Leap.Repo,
  schema: Leap.Accounts.Schema.Session

config :leap, :pow,
  user: Leap.Accounts.Schema.User,
  repo: Leap.Repo,
  cache_store_backend: Pow.Postgres.Store,
  web_module: LeapWeb

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

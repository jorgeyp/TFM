# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :extracerebrum, ExtracerebrumWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Yj56Qopu/Jy3ldsB925gSabsTXAgFBTYZw8umC3f0sXDq39qdgU3uOFHp4CsB8hW",
  render_errors: [view: ExtracerebrumWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Extracerebrum.PubSub,
  live_view: [signing_salt: "AYZcLMcY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# https://rdf-elixir.dev/sparql-ex/sparql-client-configuration.html
config :tesla, :adapter, Tesla.Adapter.Hackney
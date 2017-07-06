# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :easy_fix_api,
  ecto_repos: [EasyFixApi.Repo]

# Configures the endpoint
config :easy_fix_api, EasyFixApi.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GXA/2t6xovuVZHkDqMEie6sTQ0aypucKoOGe5oQtfvGzw2iDsL1v5AkdhvHEdhlV",
  render_errors: [view: EasyFixApi.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EasyFixApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"], # optional
  verify_module: Guardian.JWT,  # optional
  issuer: "EasyFixApi",
  ttl: { 30, :days },
  verify_issuer: true, # optional
  # TODO: move the value of the key "k" to System.get_env("GUARDIAN_SECRET_KEY")
  secret_key: %{"kty" => "oct", "k" => "YPx2Y7xdKEoS1zP7D9rZzVJMuo96DlAT8Sc7NQbPvAg1WfyhuKwuiuhHMSXKGsKBOfOCX3FTdJDkNH8nY-7HMA"},
  serializer: EasyFixApi.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

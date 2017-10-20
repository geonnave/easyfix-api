# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :easy_fix_api,
  ecto_repos: [EasyFixApi.Repo]

# Configuration for fees and fixed prices.
# A `price` is a fixed value that is charged from someone.
# A `fee` is a percentage that EasyFix collects over any fixed or dynamic price.
config :easy_fix_api, :fees,
  customer_fee_on_quote_by_garage: [percent_fee: 0.1, max_amount: 70_00],
  fixer_fee_on_service_by_fixer: [percent_fee: 0.2, max_amount: :infinity],
  customer_price_of_diagnosis_by_fixer: 15_00,
  fixer_fee_on_diagnosis_by_fixer: 0.2

# Configures the endpoint
config :easy_fix_api, EasyFixApiWeb.Endpoint,
  secret_key_base: "GXA/2t6xovuVZHkDqMEie6sTQ0aypucKoOGe5oQtfvGzw2iDsL1v5AkdhvHEdhlV",
  url: [host: "localhost"],
  render_errors: [view: EasyFixApiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: EasyFixApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :easy_fix_api, EasyFixApi.Mailer,
  adapter: Bamboo.LocalAdapter

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

config :money,
  default_currency: :BRL,
  separator: ".",
  delimeter: ",",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

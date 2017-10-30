use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# EasyFixApiWeb.Endpoint.load_from_system_env/1 dynamically.
# Any dynamic configuration should be moved to such function.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.

config :easy_fix_api,
  domain: "easyfix.net.br"

config :easy_fix_api, EasyFixApiWeb.Endpoint,
  load_from_system_env: true,
  # http: [port: 5001],
  url: [host: "api.easyfix.net.br"],
  server: true,
  root: ".",
  version: Application.spec(:easy_fix_api, :vsn)

# Do not print debug messages in production
config :logger, level: :debug

# Configure your database (without credentials)
config :easy_fix_api, EasyFixApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool_size: 15

config :easy_fix_api, EasyFixApi.Mailer,
  adapter: Bamboo.MailgunAdapter,
  domain: "easyfix.net.br",
  api_key: "key-49f5d6429dafd96af42d6b65fa5dd3f5"

# Information about state
config :easy_fix_api, :order_states,
  started: [],
  created_with_diagnosis: [
    timeout: [value: [hours: 8], event: :to_quoted_by_garages],
    fixer_timeout: [value: [minutes: 30], event: :to_quoted_by_garages],
  ],
  not_quoted_by_garages: [final_state: true, macro_state: :canceled],
  quoted_by_garages: [
    timeout: [value: [hours: 2*24], event: :to_quote_accepted_by_customer]
  ],
  quote_not_accepted_by_customer: [final_state: true, macro_state: :canceled],
  quote_accepted_by_customer: [
    timeout: [value: [hours: 5*24], event: :to_finish_by_garage]
  ],
  finished_by_garage: [final_state: true],
  # timeout_on_quoted_by_garages: [final_state: true],
  timeout: [final_state: true]

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :easy_fix_api, EasyFixApiWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :easy_fix_api, EasyFixApiWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :easy_fix_api, EasyFixApiWeb.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
import_config "prod.secret.exs"

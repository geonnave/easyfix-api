use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :easy_fix_api, EasyFixApiWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :easy_fix_api, EasyFixApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "easy_fix_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Make comeonin run faster when testing
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

config :easy_fix_api, :order_states,
  started: [],
  created_with_diagnosis: [
    timeout: [value: [milliseconds: 100], event: :to_budgeted_by_garages],
    # macro_state: :pending
  ],
  not_budgeted_by_garages: [final_state: true, macro_state: :canceled],
  budgeted_by_garages: [
    timeout: [value: [milliseconds: 100], event: :to_budget_accepted_by_customer]
  ],
  budget_not_accepted_by_customer: [final_state: true, macro_state: :canceled],
  budget_accepted_by_customer: [
    timeout: [value: [milliseconds: 100], event: :to_finish_by_garage]
  ],
  finished_by_garage: [final_state: true],
  timeout: [final_state: true]

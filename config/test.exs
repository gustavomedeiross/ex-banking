use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :banking, Banking.Repo,
  username: "postgres",
  password: "secret",
  database: "banking_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :banking, Banking.EventStoreDB,
  connection_string: "esdb://localhost:2113"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :banking, BankingWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

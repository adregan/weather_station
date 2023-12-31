import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :weather_station, WeatherStation.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "weather_station_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :weather_station, Oban, testing: :manual

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :weather_station, WeatherStationWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "emFV9CWalxNl1FXAnQTTSzW3StTKNv3vqD6kXOrdYPEX5A1WfsSdCFQoVIs1MUX0",
  server: false

# In test we don't send emails.
config :weather_station, WeatherStation.Mailer, adapter: Swoosh.Adapters.Test

config :weather_station, clock: WeatherStation.Test.Support.TimeTravelingClock

config :weather_station, Req.Request, adapter: &WeatherStation.Test.Support.ReqAdapter.adapter/1

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :weather_station,
  tempest_client_id: "TESTTESTTESTTEST_CLIENT_ID",
  tempest_client_secret: "TESTTESTTESTTEST_CLIENT_SECRET"

# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :weather_station,
  ecto_repos: [WeatherStation.Repo]

config :weather_station, refresh_rate_in_seconds: 60

# Configures the endpoint
config :weather_station, WeatherStationWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: WeatherStationWeb.ErrorHTML, json: WeatherStationWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: WeatherStation.PubSub,
  live_view: [signing_salt: "jyOQF0SC"]

config :weather_station, Req.Request, adapter: &Req.Steps.run_finch/1

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :weather_station, WeatherStation.Mailer, adapter: Swoosh.Adapters.Local

# Configures the clock to allow for mocking in tests
config :weather_station, clock: DateTime

config :weather_station, Oban,
  repo: WeatherStation.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, observations: 10]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(./js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

defmodule WeatherStation.Repo do
  use Ecto.Repo,
    otp_app: :weather_station,
    adapter: Ecto.Adapters.Postgres
end

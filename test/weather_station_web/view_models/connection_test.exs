defmodule WeatherStationWeb.ViewModels.ConnectionTest do
  use ExUnit.Case, async: true
  import WeatherStationWeb.ViewModels.Connection, only: [connection_status: 2]
  alias WeatherStationWeb.ViewModels.OutdoorObservation

  @clock Application.compile_env(:weather_station, :clock)
  @refresh_rate Application.compile_env(:weather_station, :refresh_rate_in_seconds)

  setup do
    on_exit(:unfreeze_time, fn -> @clock.unfreeze() end)

    user = %WeatherStation.Accounts.User{
      id: Ecto.UUID.generate(),
      auth_code: WeatherStation.AuthCode.generate(8),
      session_key: Ecto.UUID.generate()
    }

    token = %WeatherStation.Oauth.Token{
      id: 1,
      token: Ecto.UUID.generate(),
      service: Enum.random([:tempest, :ecobee]),
      location: Enum.random([:indoor, :outdoor]),
      user_id: user.id
    }

    %{token: token, user: user}
  end

  test "connection_status called with a nil token returns :disconnected" do
    token = nil
    assert connection_status(token, nil) == :disconnected
  end

  test "connection_status called with a nil observation returns :pending", context do
    assert connection_status(context.token, nil) == :pending
  end

  test "connection_status called with an errored observation returns :disconnected", context do
    assert connection_status(context.token, %OutdoorObservation{accessed_at: nil}) == :disconnected
  end

  test "connection_status with an observation more recent than refresh_rate is :connected", context do
    observation_time = DateTime.utc_now()

    observation = to_observation(observation_time)

    @clock.freeze(DateTime.add(observation_time, @refresh_rate - 2, :second))

    assert connection_status(context.token, observation) == :connected
  end

  test "connection_status called with a less recent observation returns :degraded", context do
    observation_time = DateTime.utc_now()

    observation = to_observation(observation_time)

    @clock.freeze(DateTime.add(observation_time, @refresh_rate + 120, :second))

    assert connection_status(context.token, observation) == :degraded
  end

  test "connection_status called with an older observation returns :disconnected", context do
    observation_time = DateTime.utc_now()

    observation = to_observation(observation_time)

    @clock.freeze(DateTime.add(observation_time, @refresh_rate * 6, :second))

    assert connection_status(context.token, observation) == :disconnected
  end

  def to_observation(accessed_at) do
    %OutdoorObservation{
      accessed_at: accessed_at,
      barometric_pressure: 1000,
      feels_like: 12.6,
      humidity: 89,
      temperature: 12.6
    }
  end
end

defmodule WeatherStation.ConnectionTest do
  use ExUnit.Case, async: true
  import WeatherStation.Connection, only: [connection_status: 2]
  alias WeatherStation.Observations.Observation

  @clock Application.compile_env(:weather_station, :clock)
  @refresh_rate Application.compile_env(:weather_station, :refresh_rate_in_seconds)

  @token %WeatherStation.Oauth.Token{
    user_id: Faker.UUID.v4(),
    token: Faker.UUID.v4(),
    location: :outdoor,
    service: :tempest
  }

  setup do
    on_exit(:unfreeze_time, fn -> @clock.unfreeze() end)
  end

  test "connection_status called with a nil token returns :disconnected" do
    token = nil
    assert connection_status(token, nil) == :disconnected
  end

  test "connection_status called with a nil observation returns :pending" do
    assert connection_status(@token, nil) == :pending
  end

  test "connection_status called with an errored observation returns :disconnected" do
    assert connection_status(@token, {:error, %{}}) == :disconnected
  end

  test "connection_status with an observation more recent than refresh_rate is :connected" do
    observation_time = DateTime.utc_now()
    observation = %Observation{
      temperature: 16.6,
      humidity: 96,
      feels_like: 16.6,
      location: :outdoor,
      accessed_at: observation_time
    }

    @clock.freeze(DateTime.add(observation_time, @refresh_rate - 2, :second))

    assert connection_status(@token, {:ok, observation}) == :connected
  end

  test "connection_status called with a less recent observation returns :degraded" do
    observation_time = DateTime.utc_now()
    observation = %Observation{
      temperature: 16.6,
      humidity: 96,
      feels_like: 16.6,
      location: :outdoor,
      accessed_at: observation_time
    }

    @clock.freeze(DateTime.add(observation_time, @refresh_rate + 120, :second))

    assert connection_status(@token, {:ok, observation}) == :degraded
  end

  test "connection_status called with an older observation returns :disconnected" do
    observation_time = DateTime.utc_now()
    observation = %Observation{
      temperature: 16.6,
      humidity: 96,
      feels_like: 16.6,
      location: :outdoor,
      accessed_at: observation_time
    }

    @clock.freeze(DateTime.add(observation_time, @refresh_rate * 6, :second))

    assert connection_status(@token, {:ok, observation}) == :disconnected
  end
end

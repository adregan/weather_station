defmodule WeatherStation.ObservationTest do
  use ExUnit.Case, async: true
  alias WeatherStation.Observations
  alias WeatherStation.Oauth.Token

  @clock Application.compile_env(:weather_station, :clock)
  @token %Token{
    service: :tempest,
    location: :outdoor,
    token: Faker.UUID.v4(),
    user_id: Faker.UUID.v4()
  }

  setup do
    start_link_supervised!(WeatherStation.ObservationServer)
    on_exit(fn -> @clock.unfreeze end)
    :ok
  end

  test "get_observation returns an observation" do
    @clock.freeze()

    assert Observations.get_observation(@token) ==
             {:ok,
              %WeatherStation.Observations.Observation{
                temperature: 29.1,
                humidity: 77,
                feels_like: 21.4,
                location: :outdoor,
                accessed_at: @clock.utc_now()
              }}
  end
end

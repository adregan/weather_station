defmodule WeatherStation.Observations.ObservationServerTest do
  use ExUnit.Case, async: true
  alias WeatherStation.Observations.ObservationServer
  alias WeatherStation.Auth.Token

  setup do
    start_supervised!(WeatherStation.Observations.ObservationServer)
    :ok
  end

  test "a caller can request observations" do
    observations =
      %Token{
        service: :tempest,
        location: :outdoor,
        token: Faker.UUID.v4(),
        user_id: Faker.UUID.v4()
      }
      |> ObservationServer.latest_observations()

    assert observations ==
             {:ok,
              %WeatherStation.Observations.Observation{
                temperature: 29.1,
                humidity: 77,
                feels_like: 21.4,
                location: :outdoor,
                accessed_at: ~U[2023-08-23 13:33:34Z]
              }}
  end
end

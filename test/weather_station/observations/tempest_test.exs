defmodule WeatherStation.Observations.TempestTest do
  use ExUnit.Case, async: true
  alias WeatherStation.Observations.Tempest

  test "when given a working token, fetch_observations returns the latest observations" do
    token = %WeatherStation.Auth.Token{
      service: :tempest,
      location: :outdoor,
      user_id: Faker.UUID.v4(),
      token: Faker.UUID.v4()
    }

    assert Tempest.fetch_observations(token) ==
             {:ok,
              %WeatherStation.Observations.Observation{
                temperature: 29.1,
                humidity: 77,
                feels_like: 21.4,
                location: :outdoor,
                accessed_at: WeatherStation.TestUtils.DateTime.utc_now()
              }}
  end

  test "when getting the station id fails, an error is returned" do
    token = %WeatherStation.Auth.Token{
      service: :tempest,
      location: :outdoor,
      user_id: Faker.UUID.v4(),
      token: "ALWAYS_ERROR_STATION"
    }

    assert Tempest.fetch_observations(token) ==
             {:error, "Something went wrong getting the station id."}
  end

  test "when getting observations fails, an error is returned" do
    token = %WeatherStation.Auth.Token{
      service: :tempest,
      location: :outdoor,
      user_id: Faker.UUID.v4(),
      token: "ALWAYS_ERROR_OBSERVATIONS"
    }

    assert Tempest.fetch_observations(token) ==
             {:error, "Something went wrong getting observations from the station."}
  end
end

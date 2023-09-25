defmodule WeatherStation.Observations.TempestTest do
  use ExUnit.Case, async: true
  alias WeatherStation.Observations.Tempest

  @clock Application.compile_env(:weather_station, :clock)

  setup do
    on_exit(:unfreeze_time, fn -> @clock.unfreeze() end)
  end

  test "when given a working token, fetch_observations returns the latest observations" do
    @clock.freeze()

    token = %WeatherStation.Oauth.Token{
      service: :tempest,
      location: :outdoor,
      user_id: Faker.UUID.v4(),
      token: Faker.UUID.v4()
    }

    assert Tempest.fetch_observation(token) == {:ok, observation_data()}
  end

  test "when getting the station id fails, an error is returned" do
    token = %WeatherStation.Oauth.Token{
      service: :tempest,
      location: :outdoor,
      user_id: Faker.UUID.v4(),
      token: "ALWAYS_ERROR_STATION"
    }

    assert Tempest.fetch_observation(token) ==
             {:error,
              %{
                service: :tempest,
                location: :outdoor,
                error_code: :error_station_id
              }}
  end

  test "when getting observations fails, an error is returned" do
    token = %WeatherStation.Oauth.Token{
      service: :tempest,
      location: :outdoor,
      user_id: Faker.UUID.v4(),
      token: "ALWAYS_ERROR_OBSERVATIONS"
    }

    assert Tempest.fetch_observation(token) ==
             {:error,
              %{
                service: :tempest,
                location: :outdoor,
                error_code: :error_observation
              }}
  end

  def observation_data do
    %{
      "timestamp" => 1_495_732_068,
      "air_temperature" => 29.1,
      "barometric_pressure" => 1002.9,
      "sea_level_pressure" => 1004.7,
      "relative_humidity" => 77,
      "precip" => 0,
      "precip_accum_last_1hr" => 0,
      "wind_avg" => 3.5,
      "wind_direction" => 289,
      "wind_gust" => 5.1,
      "wind_lull" => 2.2,
      "solar_radiation" => 330,
      "uv" => 8,
      "brightness" => 7000,
      "lightning_strike_last_epoch" => 1_495_652_340,
      "lightning_strike_last_distance" => 22,
      "lightning_strike_count_last_3hr" => 0,
      "feels_like" => 21.4,
      "heat_index" => 21.4,
      "wind_chill" => 21.4,
      "dew_point" => 17.2,
      "wet_bulb_temperature" => 18.6,
      "delta_t" => -2.8,
      "air_density" => 1.18257,
      "air_temperature_indoor" => 29.1,
      "barometric_pressure_indoor" => 1002.9,
      "sea_level_pressure_indoor" => 1004.7,
      "relative_humidity_indoor" => 77,
      "precip_indoor" => 0,
      "precip_accum_last_1hr_indoor" => 0,
      "wind_avg_indoor" => 3.5,
      "wind_direction_indoor" => 289,
      "wind_gust_indoor" => 5.1,
      "wind_lull_indoor" => 2.2,
      "solar_radiation_indoor" => 330,
      "uv_indoor" => 8,
      "brightness_indoor" => 7000,
      "lightning_strike_last_epoch_indoor" => 1_495_652_340,
      "lightning_strike_last_distance_indoor" => 22,
      "lightning_strike_count_last_3hr_indoor" => 0,
      "feels_like_indoor" => 21.4,
      "heat_index_indoor" => 21.4,
      "wind_chill_indoor" => 21.4,
      "dew_point_indoor" => 17.2,
      "wet_bulb_temperature_indoor" => 18.6,
      "delta_t_indoor" => -2.8,
      "air_density_indoor" => 1.18257
    }
  end
end

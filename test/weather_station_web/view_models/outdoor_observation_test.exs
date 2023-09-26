defmodule WeatherStationWeb.ViewModels.OutdoorObservationTest do
  use ExUnit.Case, async: true

  alias WeatherStation.Observations.Observation
  alias WeatherStationWeb.ViewModels.OutdoorObservation

  describe "Outdoor Observation" do
    test "transform/2 with nil observation returns empty observation" do
      assert OutdoorObservation.transform(nil, :tempest) == %OutdoorObservation{}
    end

    test "transform/2 with tempest observation returns an OutdoorObservation" do
      inserted_at = DateTime.utc_now()
      observation = %Observation{
        token_id: 23,
        user_id: Ecto.UUID.generate(),
        inserted_at: inserted_at,
        data: %{
          "air_temperature" => 12.6,
          "feels_like" => 11.6,
          "barometric_pressure" => 1000,
          "relative_humidity" => 81,
        }
      }
      assert OutdoorObservation.transform(observation, :tempest) == %OutdoorObservation{
        temperature: 12.6,
        feels_like: 11.6,
        barometric_pressure: 1000,
        humidity: 81,
        accessed_at: inserted_at
      }
    end

    test "transform/3 with temp_unit set to fahrenheit will convert the temp" do
      inserted_at = DateTime.utc_now()
      observation = %Observation{
        token_id: 23,
        user_id: Ecto.UUID.generate(),
        inserted_at: inserted_at,
        data: %{
          "air_temperature" => 12.6,
          "feels_like" => 11.6,
          "barometric_pressure" => 1000,
          "relative_humidity" => 81,
        }
      }
      assert OutdoorObservation.transform(observation, :tempest, temp_unit: :f) == %OutdoorObservation{
        temperature: 54.7,
        feels_like: 52.9,
        barometric_pressure: 1000,
        humidity: 81,
        accessed_at: inserted_at
      }
    end
  end
end

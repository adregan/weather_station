defmodule WeatherStationWeb.ViewModels.OutdoorObservation do
  alias WeatherStation.Observations.Observation
  import WeatherStation.Units, only: [convert_temperature: 3]

  @type t :: %__MODULE__{
          accessed_at: DateTime.t(),
          barometric_pressure: number,
          feels_like: number,
          humidity: number,
          temperature: number
        }
  defstruct accessed_at: nil,
            barometric_pressure: nil,
            feels_like: nil,
            humidity: nil,
            temperature: nil

  @type service :: :tempest
  @spec transform(Observation.t(), service(), [{:temp_unit, :c | :f}]) ::
          WeatherStationWeb.ViewModels.OutdoorObservation.t()

  def transform(observation, service, opts \\ [])

  def transform(%Observation{inserted_at: inserted_at, data: data}, :tempest, opts) do
    temp = &convert_temperature(&1, :c, Keyword.get(opts, :temp_unit, :c))

    %WeatherStationWeb.ViewModels.OutdoorObservation{
      temperature: Map.get(data, "air_temperature") |> temp.(),
      humidity: Map.get(data, "relative_humidity"),
      feels_like: Map.get(data, "feels_like") |> temp.(),
      barometric_pressure: Map.get(data, "barometric_pressure"),
      accessed_at: inserted_at
    }
  end

  def transform(nil, _, _), do: %WeatherStationWeb.ViewModels.OutdoorObservation{}
end

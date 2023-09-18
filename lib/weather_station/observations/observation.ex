defmodule WeatherStation.Observations.Observation do
  @clock Application.compile_env(:weather_station, :clock)

  defstruct temperature: nil,
            humidity: nil,
            feels_like: nil,
            location: nil,
            accessed_at: nil

  @type location :: :outdoor | :indoor
  @type t :: %__MODULE__{
    temperature: number,
    humidity: number,
    feels_like: number,
    location: location,
    accessed_at: DateTime.t()
  }

  def new(attrs \\ %{}) do
    %WeatherStation.Observations.Observation{
      accessed_at: @clock.utc_now(),
      location: Map.get(attrs, :location),
      temperature: Map.get(attrs, :temperature),
      feels_like: Map.get(attrs, :feels_like),
      humidity: Map.get(attrs, :humidity)
    }
  end
end

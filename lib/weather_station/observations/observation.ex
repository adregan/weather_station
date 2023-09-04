defmodule WeatherStation.Observations.Observation do
  @date_time_adapter if Mix.env() == :test,
                       do: WeatherStation.TestUtils.DateTime,
                       else: DateTime

  defstruct temperature: nil,
            humidity: nil,
            feels_like: nil,
            location: nil,
            accessed_at: @date_time_adapter.utc_now()
end

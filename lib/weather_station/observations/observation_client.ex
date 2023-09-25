defmodule WeatherStation.Observations.ObservationClient do
  @type error_map :: %{
          location: :outdoor | :indoor,
          service: atom(),
          error_code: atom()
        }
  @callback fetch_observation(WeatherStation.Oauth.Token.t()) ::
              {:ok, map()}
              | {:error, error_map()}
end

defmodule WeatherStation.Observations.FetchObservations do
  require Logger
  alias WeatherStation.Observations.Tempest
  alias WeatherStation.Auth.Token
  alias WeatherStation.Observations.Observation

  def with_token(%Token{service: service} = token) do
    case service do
      :tempest ->
        Tempest.fetch_observations(token)

      _ ->
        Logger.error("Fetching from service `#{service}` is not implemented")
        %Observation{}
    end
  end
end

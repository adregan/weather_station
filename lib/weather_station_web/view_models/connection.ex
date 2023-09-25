defmodule WeatherStationWeb.ViewModels.Connection do
  alias WeatherStation.Oauth.Token
  alias WeatherStationWeb.ViewModels.OutdoorObservation

  @clock Application.compile_env(:weather_station, :clock)
  @refresh_rate Application.compile_env(:weather_station, :refresh_rate_in_seconds)
  @disconnect_time @refresh_rate * 5

  @spec connection_status(Token.t(), OutdoorObservation.t()) ::
    :disconnected | :connected | :pending | :degraded

  def connection_status(nil, _), do: :disconnected

  def connection_status(%Token{}, nil), do: :pending

  def connection_status(%Token{}, %{accessed_at: nil}), do: :disconnected

  def connection_status(_, %{accessed_at: accessed_at}) do
    age = DateTime.diff(@clock.utc_now(), accessed_at)
    cond do
       age < @refresh_rate -> :connected
       age > @refresh_rate and age < @disconnect_time -> :degraded
       true -> :disconnected
    end
  end
end

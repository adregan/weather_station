defmodule WeatherStation.Connection do
  alias WeatherStation.Oauth.Token
  alias WeatherStation.Observations.Observation

  @refresh_rate Application.compile_env(:weather_station, :refresh_rate_in_seconds) * 1000
  @disconnect_time @refresh_rate * 5

  @spec connection_status(Token.t(), {:ok, Observation.t()} | {:error, Map.t()}) ::
    :disconnected | :connected | :pending | :degraded

  def connection_status(%Token{}, nil), do: :pending

  def connection_status(nil, _), do: :disconnected

  def connection_status(%Token{}, {:error, _}), do: :disconnected

  def connection_status(_, {:ok, %Observation{accessed_at: accessed_at}}) do
    age = DateTime.diff(accessed_at, DateTime.utc_now())
    cond do
       age < @refresh_rate -> :connected
       age > @refresh_rate and age < @disconnect_time -> :degraded
       true -> :disconnected
    end
  end
end

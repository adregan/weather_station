defmodule WeatherStation.Observations.Tempest do
  require Logger

  alias Req
  alias WeatherStation.Observations.Observation
  alias WeatherStation.Auth.Token

  @tempest_rest Req.new(base_url: "https://swd.weatherflow.com/swd/rest")
  @adapter if Mix.env() == :test,
             do: &WeatherStation.Observations.TestUtils.adapter/1,
             else: &Req.Steps.run_finch/1
  @date_time_adapter if Mix.env() == :test,
                       do: WeatherStation.TestUtils.DateTime,
                       else: DateTime

  def fetch_observations(%Token{} = token) do
    token
    |> get_station_id()
    |> get_station_observations(token)
  end

  defp get_station_id(%Token{token: access_token}) do
    case Req.get(@tempest_rest,
           adapter: @adapter,
           url: "/stations",
           auth: {:bearer, access_token}
         ) do
      {:ok, %Req.Response{status: 200} = response} ->
        response
        |> get_in_body("stations")
        |> Enum.map(&Map.get(&1, "station_id"))
        |> hd()
        |> then(&{:ok, &1})

      {:ok, %Req.Response{status: status} = response} ->
        Logger.info("""
          [#{__MODULE__}][#{inspect(__ENV__.function)}]: Error getting station id.
          Status: #{status}
          Response: #{response}
        """)

        {:error, "Something went wrong getting the station id."}

      {:error, exception} ->
        Logger.error("[#{__MODULE__}][#{inspect(__ENV__.function)}]: #{inspect(exception)}")
        {:error, "Something went wrong getting the station id."}
    end
  end

  defp get_station_observations({:ok, station_id}, %Token{token: access_token} = token) do
    case Req.get(@tempest_rest,
           adapter: @adapter,
           url: "/observations/station/#{station_id}",
           auth: {:bearer, access_token}
         ) do
      {:ok, %Req.Response{status: 200} = response} ->
        response
        |> get_in_body("obs")
        |> hd()
        |> Map.take(["air_temperature", "relative_humidity", "feels_like"])
        |> to_observation(token.location)
        |> then(&{:ok, &1})

      {:ok, %Req.Response{status: status} = response} ->
        Logger.info("""
          [#{__MODULE__}][#{inspect(__ENV__.function)}]: Error getting observations.
          Status: #{status}
          Response: #{response}
        """)

        {:error, "Something went wrong getting observations from the station."}

      {:error, exception} ->
        Logger.error("[#{__MODULE__}][#{inspect(__ENV__.function)}]: #{inspect(exception)}")
        {:error, "Something went wrong getting observations from the station."}
    end
  end

  defp get_station_observations({:error, _} = error, _), do: error

  defp to_observation(
         %{
           "air_temperature" => temperature,
           "relative_humidity" => humidity,
           "feels_like" => feels_like
         },
         location
       ) do
    %Observation{
      temperature: temperature,
      humidity: humidity,
      feels_like: feels_like,
      location: location,
      accessed_at: @date_time_adapter.utc_now()
    }
  end

  defp get_in_body(%Req.Response{body: body}, key) do
    Map.get(body, key)
  end
end

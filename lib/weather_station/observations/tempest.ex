defmodule WeatherStation.Observations.Tempest do
  require Logger

  alias Req
  alias WeatherStation.Oauth.Token
  alias WeatherStation.Observations.ObservationClient

  @behaviour WeatherStation.Observations.ObservationClient

  @tempest_rest Req.new(base_url: "https://swd.weatherflow.com/swd/rest")
  @adapter Application.compile_env(:weather_station, Req.Request) |> Keyword.get(:adapter)

  @impl ObservationClient
  def fetch_observation(%Token{} = token) do
    with {:ok, station_id} <- station_id(token),
         {:ok, observation_data} <- station_observation(station_id, token) do
      {:ok, observation_data}
    else
      error_code when error_code in [:error_station_id, :error_observation] ->
        error_resp(error_code)

      error ->
        Logger.warning("[#{__MODULE__}][#{inspect(__ENV__.function)}]: #{inspect(error)}")
        error_resp(:unknown_error)
    end
  end

  defp error_resp(error_code),
    do: {:error, %{location: :outdoor, service: :tempest, error_code: error_code}}

  defp station_id(%Token{token: access_token}) do
    Req.get(@tempest_rest,
      adapter: @adapter,
      url: "/stations",
      auth: {:bearer, access_token}
    )
    |> handle_station_id_response()
  end

  defp handle_station_id_response({:ok, %Req.Response{status: 200} = response}) do
    response.body
    |> Map.get("stations", [])
    |> List.first(%{})
    |> Map.get("station_id")
    |> case do
      nil -> :error_station_id
      station_id -> {:ok, station_id}
    end
  end

  defp handle_station_id_response({:ok, %Req.Response{status: status} = response}) do
    Logger.info(
      "[#{__MODULE__}]: Error getting station id. Status: #{status} Response: #{response}"
    )

    :error_station_id
  end

  defp handle_station_id_response({:error, reason}) do
    Logger.error("[#{__MODULE__}]: #{inspect(reason)}")
    :error_station_id
  end

  defp station_observation(station_id, %Token{token: access_token}) do
    Req.get(@tempest_rest,
      adapter: @adapter,
      url: "/observations/station/#{station_id}",
      auth: {:bearer, access_token}
    )
    |> handle_observation_response()
  end

  defp handle_observation_response({:ok, %Req.Response{status: 200} = response}) do
    observation_data =
      response.body
      |> Map.get("obs", [])
      |> List.first(%{})

    {:ok, observation_data}
  end

  defp handle_observation_response({:ok, %Req.Response{status: status} = response}) do
    Logger.info(
      "[#{__MODULE__}]: Error getting observations. Status: #{status} Response: #{response}"
    )

    :error_observation
  end

  defp handle_observation_response({:error, reason}) do
    Logger.error("[#{__MODULE__}]: #{inspect(reason)}")
    :error_observation
  end
end

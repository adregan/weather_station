defmodule WeatherStation.Tempest do
  use WeatherStationWeb, :html
  use Tesla
  require Logger

  plug Tesla.Middleware.BaseUrl, "https://swd.weatherflow.com"
  plug Tesla.Middleware.FormUrlencoded

  defp client_id do
    Application.fetch_env!(:weather_station, :tempest_client_id)
  end

  defp client_secret do
    Application.fetch_env!(:weather_station, :tempest_client_secret)
  end

  def authorize_link() do
    params = %{
      client_id: client_id(),
      response_type: "code",
      redirect_uri: url(~p"/authorize"),
      state: "outdoor:tempest"
    }

    "https://tempestwx.com/authorize.html?#{URI.encode_query(params)}"
  end

  def access_token(code) do
    req_params = %{
      grant_type: "authorization_code",
      code: code,
      client_id: client_id(),
      client_secret: client_secret()
    }

    case post("/id/oauth2/token", req_params) do
      {:ok, %{status: 200, body: body}} ->
        token =
          Jason.decode!(body)
          |> Map.get("access_token")

        {:ok, token}

      {:ok, %{status: 401} = response} ->
        # safer to not pattern match on the shape of the error responses from the api
        error_description =
          Map.get(response, :body, "")
          |> decode_and_get("error_description", "Unauthorized request to Tempest")

        {:error, "Unauthorized request to the tempest server: #{error_description}"}

      {:ok, %{status: status} = response} ->
        {:error, "Request failed with status: #{status} Response was: #{inspect(response)}"}

      {:error, reason} ->
        {:error, "Something went wrong: #{inspect(reason)}"}
    end
  end

  defp decode_and_get(data, key, default) do
    case Jason.decode(data) do
      {:ok, decoded} ->
        Map.get(decoded, key, default)

      {:error, decode_error} ->
        Logger.warning(
          "Something went wrong decoding the json from Tempest: #{inspect(decode_error)}"
        )

        default
    end
  end
end

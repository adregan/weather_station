defmodule WeatherStation.Tempest do
  use WeatherStationWeb, :html
  use Tesla

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
        %{"access_token" => access_token} = Jason.decode!(body)
        {:ok, access_token}

      {:ok, %{status: 401, body: body}} ->
        %{"error_description" => error_description} = Jason.decode!(body)
        {:error, "Unauthorized request to the tempest server: #{error_description}"}

      {:ok, %{status: status} = response} ->
        {:error,
         """
           Request failed with status: #{status}
           Response was: #{inspect(response)}
         """}

      {:error, reason} ->
        {:error, "Something went wrong: #{inspect(reason)}"}
    end
  end
end

defmodule WeatherStation.Oauth.Tempest do
  use WeatherStationWeb, :html
  alias Req
  require Logger

  @tempest Req.new(base_url: "https://swd.weatherflow.com")
  @client_id Application.compile_env(:weather_station, :tempest_client_id)
  @client_secret Application.compile_env(:weather_station, :tempest_client_secret)
  @adapter Application.compile_env(:weather_station, Req.Request) |> Keyword.get(:adapter)

  def authorize_link() do
    params = %{
      client_id: @client_id,
      response_type: "code",
      redirect_uri: url(~p"/authorize/callback"),
      state: "outdoor:tempest"
    }

    "https://tempestwx.com/authorize.html?#{URI.encode_query(params)}"
  end

  def access_token(code) do
    Req.post(@tempest,
      adapter: @adapter,
      url: "/id/oauth2/token",
      form: %{
        grant_type: "authorization_code",
        code: code,
        client_id: @client_id,
        client_secret: @client_secret
      }
    )
    |> handle_access_token_response()
  end

  defp handle_access_token_response({:ok, %{status: 200} = response}) do
    %{"access_token" => access_token} = response.body
    {:ok, access_token}
  end

  defp handle_access_token_response({:ok, %{status: status} = response}) do
    errors =
      response.body
      |> Map.get("errors")
      |> Enum.reduce([], fn %{"message" => message}, acc -> acc ++ [message] end)
      |> Enum.join(" - ")

    {:error, "Request failed with status: #{status}. Errors were: #{errors}"}
  end

  defp handle_access_token_response({:error, exception}) do
    {:error, "Something went wrong: #{inspect(exception)}"}
  end
end

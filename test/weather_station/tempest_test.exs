defmodule WeatherStation.TempestTest do
  alias WeatherStation.Tempest
  use ExUnit.Case

  test "authorize_link produces valid oauth link parameters" do
    tempest = "https://tempestwx.com/authorize.html"
    port = Application.fetch_env!(:weather_station, WeatherStationWeb.Endpoint)[:http][:port]
    client_id = Application.fetch_env!(:weather_station, :tempest_client_id)

    [^tempest, query] = Tempest.authorize_link() |> String.split("?")

    assert URI.decode_query(query) ==
             %{
               "client_id" => client_id,
               "response_type" => "code",
               "redirect_uri" => "http://localhost:#{port}/authorize",
               "state" => "outdoor:tempest"
             }
  end

  test "token request reports an error when request 404s" do
    status_code = 404
    messages = [%{message: "oh no"}, %{message: "not good"}]

    {status, reason} = Tempest.access_token("124456899", error_adapter(status_code, messages))
    assert status == :error

    assert reason ==
             "Request failed with status: #{status_code}. Errors were: #{messages_to_string(messages)}"
  end

  test "token request reports an error when request 401s" do
    status_code = 401
    messages = [%{message: "uh oh. Don't do that"}]

    {status, reason} = Tempest.access_token("934893209", error_adapter(status_code, messages))
    assert status == :error

    assert reason ==
             "Request failed with status: #{status_code}. Errors were: #{messages_to_string(messages)}"
  end

  test "token request returns the access token" do
    access_token = "really-nice-token"

    {status, token} = Tempest.access_token("wowwowowwowowow", success_adapter(access_token))
    assert status == :ok
    assert token == access_token
  end

  defp error_adapter(status, messages) do
    fn request ->
      response =
        %Req.Response{status: status}
        |> Req.Response.json(%{errors: messages})

      {request, response}
    end
  end

  defp success_adapter(access_token) do
    fn request ->
      response =
        %Req.Response{status: 200}
        |> Req.Response.json(%{access_token: access_token})

      {request, response}
    end
  end

  defp messages_to_string(messages) do
    for %{message: message} <- messages, into: [] do
      message
    end
    |> Enum.join(" - ")
  end
end

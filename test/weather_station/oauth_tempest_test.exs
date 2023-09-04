defmodule WeatherStation.TempestTest do
  alias WeatherStation.Oauth.Tempest
  use ExUnit.Case, async: true

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
    {status, reason} = Tempest.access_token("ALWAYS_404")
    assert status == :error
    assert reason == "Request failed with status: 404. Errors were: Not Found"
  end

  test "token request reports an error when request 401s" do
    {status, reason} = Tempest.access_token("ALWAYS_401")
    assert status == :error
    assert reason == "Request failed with status: 401. Errors were: Unauthorized"
  end

  test "token request returns the access token" do
    {status, token} = Tempest.access_token("123456789")
    assert status == :ok
    assert token == "THIS_IS_YOUR_ACCESS_TOKEN"
  end
end

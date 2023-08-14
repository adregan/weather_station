defmodule WeatherStation.TempestTest do
  alias WeatherStation.Tempest
  use ExUnit.Case

  import Tesla.Mock

  @client_id "123456789"
  @client_secret "abcdefghi"
  @tempest_token_api "https://swd.weatherflow.com/id/oauth2/token"

  setup do
    Application.put_env(:weather_station, :tempest_client_id, @client_id)
    Application.put_env(:weather_station, :tempest_client_secret, @client_secret)
  end

  test "authorize_link produces valid oauth link parameters" do
    tempest = "https://tempestwx.com/authorize.html"
    port = Application.fetch_env!(:weather_station, WeatherStationWeb.Endpoint)[:http][:port]

    [^tempest, query] = Tempest.authorize_link() |> String.split("?")

    assert URI.decode_query(query) ==
             %{
               "client_id" => @client_id,
               "response_type" => "code",
               "redirect_uri" => "http://localhost:#{port}/authorize",
               "state" => "outdoor:tempest"
             }
  end

  test "token request reports an error when request 404s" do
    mock(fn
      %{method: :post, url: @tempest_token_api} -> %Tesla.Env{status: 404}
    end)

    {status, reason} = Tempest.access_token("124456899")
    assert status == :error
    assert String.starts_with?(reason, "Request failed with status: 404") == true
  end

  test "token request reports an error when request 401s" do
    error_description = "uh oh. Don't do that"

    mock(fn
      %{method: :post, url: @tempest_token_api} ->
        %Tesla.Env{status: 401, body: Jason.encode!(%{error_description: error_description})}
    end)

    {status, reason} = Tempest.access_token("934893209")
    assert status == :error
    assert reason == "Unauthorized request to the tempest server: #{error_description}"
  end

  test "token request reports all other server errors" do
    response = %Tesla.Env{status: 500, body: Jason.encode!(%{wow: "not a good idea"})}

    mock(fn
      %{method: :post, url: @tempest_token_api} -> response
    end)

    {status, reason} = Tempest.access_token("2323923902")
    assert status == :error
    assert reason == "Request failed with status: 500 Response was: #{inspect(response)}"
  end

  test "token request reports errors from Tesla" do
    response = {:error, "out of service"}

    mock(fn
      %{method: :post, url: @tempest_token_api} -> response
    end)

    {status, reason} = Tempest.access_token("2323924038")
    assert status == :error
    assert reason == "Something went wrong: #{inspect(elem(response, 1))}"
  end

  test "token request returns the access token" do
    access_token = "really-nice-token"

    mock(fn
      %{method: :post, url: @tempest_token_api} ->
        %Tesla.Env{status: 200, body: Jason.encode!(%{access_token: access_token})}
    end)

    {status, token} = Tempest.access_token("wowwowowwowowow")
    assert status == :ok
    assert token == access_token
  end
end

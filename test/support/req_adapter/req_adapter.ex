defmodule WeatherStation.Test.Support.ReqAdapter do
  alias Req.Request
  alias WeatherStation.Test.Support.ReqAdapter.Token
  alias WeatherStation.Test.Support.ReqAdapter.Station
  alias WeatherStation.Test.Support.ReqAdapter.Stations

  def adapter(%Request{url: url} = request) do
    case url.host <> url.path do
      "swd.weatherflow.com/id/oauth2/token" ->
        Token.adapter(request)

      "swd.weatherflow.com/swd/rest/stations" ->
        Stations.adapter(request)

      "swd.weatherflow.com/swd/rest/observations/station/" <> _ ->
        Station.adapter(request)

      _ ->
        {request,
         Req.Response.new(
           status: 500,
           body: "Adapter not implemented for #{inspect(url)}"
         )}
    end
  end
end

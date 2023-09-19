defmodule WeatherStation.Test.Support.ReqAdapter.Stations do
  alias Req.Request

  def adapter(%Request{options: %{auth: {:bearer, "ALWAYS_ERROR_STATION"}}} = request) do
    {request,
     Req.Response.new(
       status: 404,
       body: "Error occurred: Station is down."
     )}
  end

  def adapter(%Request{} = request) do
    {request,
     Req.Response.json(%{
       "stations" => [
         %{
           "name" => Faker.Pokemon.name(),
           "public_name" => Faker.Pokemon.name(),
           "station_id" => :rand.uniform(100_000)
         }
       ]
     })}
  end
end

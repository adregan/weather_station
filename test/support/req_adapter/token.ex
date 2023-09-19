defmodule WeatherStation.Test.Support.ReqAdapter.Token do
  alias Req.Request

  def adapter(%Request{options: %{form: %{code: "ALWAYS_404"}}} = request) do
    {request,
     Req.Response.new(status: 404)
     |> Req.Response.json(%{errors: [%{message: "Not Found"}]})}
  end

  def adapter(%Request{options: %{form: %{code: "ALWAYS_401"}}} = request) do
    {request,
     Req.Response.new(status: 401)
     |> Req.Response.json(%{errors: [%{message: "Unauthorized"}]})}
  end

  def adapter(%Req.Request{} = request) do
    {request, Req.Response.json(%{access_token: "THIS_IS_YOUR_ACCESS_TOKEN"})}
  end
end

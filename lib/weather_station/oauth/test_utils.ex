defmodule WeatherStation.Oauth.TestUtils do
  def adapter(
        %Req.Request{
          url: %URI{host: "swd.weatherflow.com", path: "/id/oauth2/token"},
          options: %{ form: %{code: "ALWAYS_404"} }
        } = request
      ) do

    Req.Response.new(status: 404)
    |> Req.Response.json(%{errors: [%{ message: "Not Found"}]})
    |> then(&{request, &1})
  end

  def adapter(
        %Req.Request{
          url: %URI{host: "swd.weatherflow.com", path: "/id/oauth2/token"},
          options: %{ form: %{code: "ALWAYS_401"} }
        } = request
      ) do

    Req.Response.new(status: 401)
    |> Req.Response.json(%{errors: [%{ message: "Unauthorized"}]})
    |> then(&{request, &1})
  end

  def adapter(
        %Req.Request{
          url: %URI{host: "swd.weatherflow.com", path: "/id/oauth2/token"}
        } = request
      ) do

    Req.Response.json(%{access_token: "THIS_IS_YOUR_ACCESS_TOKEN"})
    |> then(&{request, &1})
  end
end

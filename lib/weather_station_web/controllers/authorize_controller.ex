defmodule WeatherStationWeb.AuthorizeController do
  use WeatherStationWeb, :controller

  require Logger

  alias WeatherStation.Oauth
  alias WeatherStation.Oauth.Tempest
  alias WeatherStation.Accounts

  def callback(conn, %{"code" => code, "state" => "outdoor:tempest"}) do
    Tempest.access_token(code)
    |> handle_token_response(conn, :tempest, :outdoor)
    |> redirect_to_settings()
  end

  def callback(conn, %{"code" => _code, "state" => state}) do
    Logger.info("[#{__MODULE__}] Received a code for an unsupported service: #{state}")
    redirect_to_settings(conn)
  end

  def callback(conn, _), do: redirect_to_settings(conn)

  defp redirect_to_settings(conn), do: redirect(conn, to: ~p"/settings")

  defp handle_token_response({:ok, token}, conn, service, location) do
    user_id =
      get_session(conn, :session_key)
      |> Accounts.get_user_by_session_key()
      |> Map.get(:id)

    {:ok, _token} =
      Oauth.create_token(%{
        user_id: user_id,
        token: token,
        service: service,
        location: location
      })

    conn
    |> put_flash(:info, "Successfully authorized #{service}")
  end

  defp handle_token_response({:error, reason}, conn, service, _) do
    Logger.info(
      "[#{__MODULE__}] received authentication error from #{service}: #{inspect(reason)}"
    )

    conn
    |> put_flash(
      :error,
      "Something went wrong authorizing #{service}, please try again"
    )
  end
end

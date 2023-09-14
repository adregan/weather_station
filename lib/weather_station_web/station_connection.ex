defmodule WeatherStationWeb.StationConnection do
  import Phoenix.Component
  alias WeatherStation.ConnectionServer
  alias WeatherStation.Oauth
  alias WeatherStation.Accounts

  def on_mount(:default, _params, session, socket) do
    user =
      session
      |> Map.get("session_key")
      |> Accounts.get_user_by_session_key()

    tokens = user |> Oauth.list_tokens_by_user()

    outdoor_token = tokens |> Enum.find(&is_outdoor_token?/1)
    indoor_token = tokens |> Enum.find(&is_indoor_token?/1)

    outdoor_connection =
      ConnectionServer.get_connection(outdoor_token, user.id, :outdoor)

    indoor_connection =
      ConnectionServer.get_connection(indoor_token, user.id, :indoor)

    socket =
      socket
      |> assign_new(:user_id, fn -> user.id end)
      |> assign_new(:auth_code, fn -> user.auth_code end)
      |> assign_new(:outdoor_connection, fn -> outdoor_connection end)
      |> assign_new(:indoor_connection, fn -> indoor_connection end)

    {:cont, socket}
  end

  defp is_indoor_token?(%Oauth.Token{location: location}), do: location == :indoor
  defp is_outdoor_token?(%Oauth.Token{location: location}), do: location == :outdoor
end

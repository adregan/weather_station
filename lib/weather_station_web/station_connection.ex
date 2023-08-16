defmodule WeatherStationWeb.StationConnection do
  import Phoenix.Component
  alias WeatherStation.Auth
  alias WeatherStation.Accounts

  def on_mount(:default, _params, session, socket) do
    user =
      session
      |> Map.get("session_key")
      |> Accounts.get_user_by_session_key()

    tokens = user |> Auth.list_tokens_by_user()

    outdoor_connection =
      tokens
      |> Enum.find(&is_outdoor_token?/1)
      |> WeatherStation.Connection.new()

    indoor_connection =
      tokens
      |> Enum.find(&is_indoor_token?/1)
      |> WeatherStation.Connection.new()

    socket =
      socket
      |> assign_new(:user_id, fn -> user.id end)
      |> assign_new(:auth_code, fn -> user.auth_code end)
      |> assign_new(:outdoor_connection, fn -> outdoor_connection end)
      |> assign_new(:indoor_connection, fn -> indoor_connection end)

    {:cont, socket}
  end

  defp is_indoor_token?(%Auth.Token{location: location}), do: location == :indoor
  defp is_outdoor_token?(%Auth.Token{location: location}), do: location == :outdoor
end

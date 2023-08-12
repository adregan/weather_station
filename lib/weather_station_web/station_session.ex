defmodule WeatherStationWeb.StationSession do
  import Phoenix.Component
  alias WeatherStation.Auth
  alias WeatherStation.Accounts

  def on_mount(:default, _params, session, socket) do
    user = session |> Map.get("session_key") |> Accounts.get_user_by_session_key()
    tokens = user |> Auth.get_tokens_by_user()

    outdoor_token = tokens |> Enum.find(fn t -> t.location == :outdoor end)
    indoor_token = tokens |> Enum.find(fn t -> t.location == :indoor end)

    socket =
      socket
      |> assign_new(:user_id, fn -> user.id end)
      |> assign_new(:auth_code, fn -> user.auth_code end)
      |> assign_new(:outdoor_token, fn -> outdoor_token end)
      |> assign_new(:indoor_token, fn -> indoor_token end)

    {:cont, socket}
  end
end

defmodule WeatherStationWeb.StationSession do
  import Phoenix.Component
  alias WeatherStation.Tokens

  def on_mount(:default, _params, session, socket) do
    user_id = session["session_id"]
    outdoor_token = Tokens.get_token_by_location(user_id, :outdoor)
    indoor_token = Tokens.get_token_by_location(user_id, :indoor)

    socket =
      socket
      |> assign_new(:user_id, fn -> user_id end)
      |> assign_new(:outdoor_token, fn -> outdoor_token end)
      |> assign_new(:indoor_token, fn -> indoor_token end)

    {:cont, socket}
  end
end

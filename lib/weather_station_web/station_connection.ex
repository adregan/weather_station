defmodule WeatherStationWeb.StationConnection do
  import Phoenix.Component

  alias WeatherStation.Observations
  alias WeatherStation.Oauth
  alias WeatherStation.Accounts

  def on_mount(:default, _params, session, socket) do
    user =
      session
      |> Map.get("session_key")
      |> Accounts.get_user_by_session_key()

    outdoor_token = user |> Oauth.get_token_by_location(:outdoor)
    indoor_token = user |> Oauth.get_token_by_location(:indoor)

    outdoor_observation = Observations.get_observation(outdoor_token)
    indoor_observation =Observations.get_observation(indoor_token)

    socket =
      socket
      |> assign_new(:user, fn -> user end)
      |> assign_new(:outdoor_token, fn -> outdoor_token end)
      |> assign_new(:indoor_token, fn -> indoor_token end)
      |> assign_new(:outdoor_observation, fn -> outdoor_observation end)
      |> assign_new(:indoor_observation, fn -> indoor_observation end)

    {:cont, socket}
  end
end

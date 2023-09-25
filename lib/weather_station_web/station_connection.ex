defmodule WeatherStationWeb.StationConnection do
  import Phoenix.Component

  alias WeatherStation.Observations
  alias WeatherStation.Oauth
  alias WeatherStation.Accounts
  alias WeatherStationWeb.ViewModels.OutdoorObservation

  def on_mount(:default, _params, session, socket) do
    user =
      session
      |> Map.get("session_key")
      |> Accounts.get_user_by_session_key()

    outdoor_token = Oauth.get_token(user: user, location: :outdoor)
    indoor_token = Oauth.get_token(user: user, location: :indoor)

    # TODO: temp_unit should be configurable from settings
    temp_unit = :f

    outdoor_observation =
      Observations.get_latest_observation(outdoor_token)
      |> OutdoorObservation.transform(outdoor_token.service, temp_unit: temp_unit)

    indoor_observation = Observations.get_latest_observation(indoor_token)

    socket =
      socket
      |> assign_new(:user, fn -> user end)
      |> assign_new(:temp_unit, fn -> temp_unit end)
      |> assign_new(:outdoor_token, fn -> outdoor_token end)
      |> assign_new(:indoor_token, fn -> indoor_token end)
      |> assign_new(:outdoor_observation, fn -> outdoor_observation end)
      |> assign_new(:indoor_observation, fn -> indoor_observation end)

    {:cont, socket}
  end
end

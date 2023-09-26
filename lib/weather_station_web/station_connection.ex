defmodule WeatherStationWeb.StationConnection do
  import Phoenix.Component

  alias WeatherStation.Oauth
  alias WeatherStation.Accounts
  alias WeatherStationWeb.ViewModels.{Connection, OutdoorObservation}
  alias WeatherStation.Observations

  def on_mount(:default, _params, session, socket) do
    user =
      session
      |> Map.get("session_key")
      |> Accounts.get_user_by_session_key()

    outdoor_token = Oauth.get_token(user: user, location: :outdoor)
    indoor_token = Oauth.get_token(user: user, location: :indoor)

    # TODO: temp_unit should be configurable from settings
    temp_unit = :f

    socket =
      socket
      |> assign_new(:user, fn -> user end)
      |> assign_new(:temp_unit, fn -> temp_unit end)
      |> assign_new(:outdoor_token, fn -> outdoor_token end)
      |> assign_new(:indoor_token, fn -> indoor_token end)
      |> assign_new(:outdoor_connection_status, fn -> :disconnected end)
      |> assign_new(:indoor_connection_status, fn -> :disconnected end)

    {:cont, socket}
  end

  defmacro __using__(_) do
    quote do
      def start_connection_heartbeat, do: send(self(), :connection_heartbeat)

      def handle_info(:connection_heartbeat, socket) do
        temp_unit = socket.assigns |> Map.get(:temp_unit)
        indoor_token = socket.assigns |> Map.get(:indoor_token)
        outdoor_token = socket.assigns |> Map.get(:outdoor_token)
        outdoor_observation = socket.assigns |> Map.get(:outdoor_observation)
        indoor_observation = socket.assigns |> Map.get(:indoor_observation)

        outdoor_observation =
          if is_nil(outdoor_observation) do
            Observations.get_latest_observation(outdoor_token)
            |> OutdoorObservation.transform(:tempest, temp_unit: temp_unit)
          else
            outdoor_observation
          end

        indoor_observation =
          if is_nil(indoor_observation) do
            Observations.get_latest_observation(indoor_token)
          else
            indoor_observation
          end

        outdoor_connection_status =
          Connection.connection_status(outdoor_token, outdoor_observation)

        indoor_connection_status =
          Connection.connection_status(indoor_token, indoor_observation)

        socket =
          socket
          |> assign(:outdoor_connection_status, outdoor_connection_status)
          |> assign(:indoor_connection_status, indoor_connection_status)

        Process.send_after(self(), :connection_heartbeat, :timer.minutes(2))

        {:noreply, socket}
      end
    end
  end
end

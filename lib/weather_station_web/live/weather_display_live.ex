defmodule WeatherStationWeb.WeatherDisplayLive do
  require Logger
  use WeatherStationWeb, :live_view
  alias WeatherStation.Observations.ObservationServer
  alias WeatherStation.Connection

  def render(assigns) do
    ~H"""
    <p><%= inspect(@observations) %></p>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      ObservationServer.subscribe()
    end

    %{ token: token } = socket.assigns.outdoor_connection
    observations = ObservationServer.latest_observations(token)

    {:ok, update_with_observations(socket, observations)}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info(
        {:observations_updated, user_id, observations},
        %{assigns: %{user_id: user_id}} = socket
      ) do
    {:noreply, update_with_observations(socket, observations)}
  end

  def handle_info(msg, socket) do
    Logger.warning("Unknown message sent to #{__MODULE__}: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  defp update_with_observations(socket, observations) do
    socket
    |> assign(:observations, observations)
    |> update_connection(observations)
  end

  defp update_connection(socket, {:ok, %{location: location}}) do
    update(socket, location_key(location), &Connection.connect/1)
  end

  defp update_connection(socket, {:error, %{location: location}}) do
    update(socket, location_key(location), &Connection.disconnect/1)
  end

  defp location_key(:outdoor), do: :outdoor_connection
  defp location_key(:indoor), do: :indoor_connection
end

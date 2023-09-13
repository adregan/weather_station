defmodule WeatherStationWeb.WeatherDisplayLive do
  require Logger
  use WeatherStationWeb, :live_view
  alias WeatherStation.Observations.ObservationServer
  alias WeatherStation.ConnectionServer

  def render(assigns) do
    ~H"""
    <p><%= inspect(@observation) %></p>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      ObservationServer.subscribe()
    end

    %{token: token} = socket.assigns.outdoor_connection
    observation = ObservationServer.latest_observation(token)

    {:ok, update_observation(socket, observation)}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info(
        {:new_observation, user_id, observation},
        %{assigns: %{user_id: user_id}} = socket
      ) do
    {:noreply, update_observation(socket, observation)}
  end

  def handle_info(msg, socket) do
    Logger.warning("Unknown message sent to #{__MODULE__}: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  defp update_observation(socket, observation) do
    socket
    |> assign(:observation, observation)
    |> update_connection(observation)
  end

  defp update_connection(socket, {:ok, %{location: location}}) do
    update(socket, location_key(location), &ConnectionServer.update(&1, :connect))
  end

  defp update_connection(socket, {:error, %{location: location}}) do
    update(socket, location_key(location), &ConnectionServer.update(&1, :degrade))
  end

  defp update_connection(socket, nil), do: socket

  defp location_key(:outdoor), do: :outdoor_connection
  defp location_key(:indoor), do: :indoor_connection
end

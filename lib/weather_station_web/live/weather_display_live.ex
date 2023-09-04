defmodule WeatherStationWeb.WeatherDisplayLive do
  use WeatherStationWeb, :live_view
  alias WeatherStation.Observations.ObservationServer
  alias WeatherStation.Connection

  def render(assigns) do
    ~H"""
    <p><%= inspect @observations %></p>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      ObservationServer.subscribe()
    end

    observations =
      socket
      |> get_in(Enum.map([:assigns, :outdoor_connection, :token], &Access.key/1))
      |> ObservationServer.latest_observations()

    {:ok, assign(socket, :observations, observations)}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info({:observations_updated, user_id, observations}, socket) do
    socket =
      if socket.assigns.user_id == user_id do
        %{location: location} = observations
        case location do
          :indoor ->
            socket |> update(:indoor_connection, &Connection.connect/1)
          :outdoor ->
            socket
            |> update(:outdoor_connection, &Connection.connect/1)
            |> assign(:observations, observations)
        end
      else
        socket
      end

    {:noreply, socket}
  end
end

defmodule WeatherStationWeb.WeatherDisplayLive do
  use WeatherStationWeb, :live_view
  use WeatherStationWeb.StationConnection

  require Logger

  alias WeatherStation.Accounts.User
  alias WeatherStation.Observations
  alias WeatherStation.Observations.Observation
  import WeatherStationWeb.ViewModels.OutdoorObservation, only: [transform: 3]

  def render(assigns) do
    ~H"""
    <p><%= inspect(@outdoor_observation) %></p>
    <p><%= inspect(@indoor_observation) %></p>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Observations.subscribe()
    end

    %{
      outdoor_token: outdoor_token,
      indoor_token: indoor_token,
      temp_unit: temp_unit
    } = socket.assigns

    outdoor_observation =
      Observations.get_latest_observation(outdoor_token)
      |> transform(outdoor_token.service, temp_unit: temp_unit)

    indoor_observation =
      Observations.get_latest_observation(indoor_token)

    socket =
      socket
      |> assign(:outdoor_observation, outdoor_observation)
      |> assign(:indoor_observation, indoor_observation)

    start_connection_heartbeat()

    {:ok, socket}
  end

  def handle_info(
        {:observation_created, %Observation{user_id: user_id} = observation},
        %{assigns: %{user: %User{id: user_id}}} = socket
      ) do
    {:noreply, update_observation(socket, observation)}
  end

  def handle_info({:observation_created, _, _}, socket), do: {:noreply, socket}

  def handle_info(msg, socket) do
    Logger.warning("Unknown message sent to #{__MODULE__}: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  def update_observation(
        %{assigns: %{indoor_token: %{id: token_id, service: _service}}} = socket,
        %{token_id: token_id} = observation
      ) do
    assign(socket, :indoor_observation, observation)
  end

  def update_observation(
        %{assigns: %{outdoor_token: %{id: token_id, service: service}}} = socket,
        %{token_id: token_id} = observation
      ) do
    observation =
      observation |> transform(service, temp_unit: socket.assigns.temp_unit)

    assign(socket, :outdoor_observation, observation)
  end
end

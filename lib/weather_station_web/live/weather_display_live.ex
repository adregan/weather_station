defmodule WeatherStationWeb.WeatherDisplayLive do
  use WeatherStationWeb, :live_view

  require Logger

  alias WeatherStation.Accounts.User
  alias WeatherStation.Observations
  alias WeatherStation.Observations.Observation
  alias WeatherStationWeb.ViewModels.OutdoorObservation

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
      observation
      |> OutdoorObservation.transform(service, temp_unit: socket.assigns.temp_unit)

    assign(socket, :outdoor_observation, observation)
  end
end

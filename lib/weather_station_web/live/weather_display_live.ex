defmodule WeatherStationWeb.WeatherDisplayLive do
  use WeatherStationWeb, :live_view

  require Logger

  alias WeatherStation.Accounts.User
  alias WeatherStation.Observations

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

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info(
        {:observation_created, user_id, observation},
        %{assigns: %{user: %User{id: user_id}}} = socket
      ) do
    {:noreply, update_observation(socket, observation)}
  end

  def handle_info({:observation_created, _, _}, socket), do: {:noreply, socket}

  def handle_info(
        {:observation_errored, user_id, error},
        %{assigns: %{user: %User{id: user_id}}} = socket
      ) do
    {:noreply, update_observation(socket, error)}
  end

  def handle_info({:observation_errored, _, _}, socket), do: {:noreply, socket}

  def handle_info(msg, socket) do
    Logger.warning("Unknown message sent to #{__MODULE__}: #{inspect(msg, pretty: true)}")
    {:noreply, socket}
  end

  def update_observation(socket, {_, %{location: :indoor}} = observation) do
    assign(socket, :indoor_observation, observation)
  end

  def update_observation(socket, {_, %{location: :outdoor}} = observation) do
    assign(socket, :outdoor_observation, observation)
  end
end

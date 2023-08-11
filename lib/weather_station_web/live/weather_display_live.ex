defmodule WeatherStationWeb.WeatherDisplayLive do
  use WeatherStationWeb, :live_view

  def render(assigns) do
    ~H"""
    <p>TODO:Weather station goes here</p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end
end

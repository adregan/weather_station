defmodule WeatherStationWeb.Header.AuthorizeComponent do
  use WeatherStationWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p><%= copy(@location) %></p>
    """
  end

  defp copy(:outdoors), do: gettext("Authorize Outdoor Sensors")
  defp copy(:indoors), do: gettext("Authorize Indoor Sensors")
end

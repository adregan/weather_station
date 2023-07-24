defmodule WeatherStationWeb.Header.HeaderComponent do
  alias WeatherStationWeb.Header.AuthorizeComponent
  use WeatherStationWeb, :live_component

  attr :indoor_connection, :map
  attr :outdoor_connection, :map

  def render(assigns) do
    ~H"""
    <header class="flex justify-center space-x-4 py-4 border-green-300 border-b-2 w-screen">
      <.auth_or_connection location={:outdoors} connection={@outdoor_connection} />
      <.auth_or_connection location={:indoors} connection={@indoor_connection} />
    </header>
    """
  end

  attr :location, :atom, required: true
  # TODO: Update to use Connection struct
  attr :connection, :map

  defp auth_or_connection(assigns) do
    ~H"""
    <%= if is_connected?(@connection) do %>
      <p>TODO: Real Connected Component!</p>
    <% else %>
      <.live_component module={AuthorizeComponent} location={@location} id={@location} />
    <% end %>
    """
  end

  defp is_connected?(connection), do: !is_nil(connection)
end

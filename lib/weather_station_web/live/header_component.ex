defmodule WeatherStationWeb.HeaderComponent do
  use WeatherStationWeb, :live_component

  alias WeatherStation.Token

  attr :indoor_token, Token
  attr :outdoor_token, Token

  def render(assigns) do
    ~H"""
    <header class="flex justify-center space-x-4 py-4 border-green-300 border-b-2 w-screen">
      <.auth_or_connection location={:outdoor} token={@outdoor_token} />
      <.auth_or_connection location={:indoor} token={@indoor_token} />
    </header>
    """
  end

  attr :location, :atom, required: true
  # TODO: Update to use Connection struct
  attr :token, Token

  defp auth_or_connection(assigns) do
    ~H"""
    <%= if !is_nil(@token) do %>
      <p>Connected: <%= @token.service %></p>
    <% else %>
      <.link navigate={~p"/authorize"}>
        Authorize <%= @location |> to_string() |> String.capitalize() %> service
      </.link>
    <% end %>
    """
  end
end

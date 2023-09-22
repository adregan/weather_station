defmodule WeatherStationWeb.AuthorizeLive do
  use WeatherStationWeb, :live_view

  alias WeatherStation.Oauth
  alias WeatherStation.Oauth.Tempest

  require Logger

  def render(assigns) do
    ~H"""
    <h2><%= gettext("Outdoor Sensors") %></h2>
    <%= if is_nil(@outdoor_token) do %>
      <ul>
        <li>
          <a href={Tempest.authorize_link(@redirect_uri)}>
            <%= gettext("Authorize with Tempest") %>
          </a>
        </li>
      </ul>
    <% else %>
      <p>
        <%= authorized_text(@outdoor_token) %>
        <.button phx-click="unauthorize-outdoor">
          <%= gettext("unauthorize") %>
        </.button>
      </p>
    <% end %>
    """
  end

  def mount(_, _, socket) do
    {:ok, assign(socket, :redirect_uri, url(~p"/authorize/callback"))}
  end

  def handle_event("unauthorize-outdoor", _, socket) do
    {:ok, _} = socket.assigns.outdoor_token |> Oauth.delete_token()
    {:noreply, assign(socket, :outdoor_token, nil)}
  end

  def handle_info(msg, socket) do
    Logger.info("[#{__MODULE__}] received unexpected message: #{inspect(msg)}")
    {:noreply, socket}
  end

  defp authorized_text(token) do
    service =
      token.service
      |> to_string()
      |> String.capitalize()

    "#{gettext("Authorized with")} #{service}!"
  end
end

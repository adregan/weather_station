defmodule WeatherStationWeb.AuthorizeComponent do
  use WeatherStationWeb, :live_component

  alias WeatherStation.Oauth
  alias WeatherStation.Oauth.Token
  alias WeatherStation.Oauth.Tempest

  def mount(socket) do
    services = %{
      outdoor: [Tempest],
      indoor: []
    }

    socket =
      socket
      |> assign(:services, services)
      |> assign(:redirect_uri, url(~p"/authorize/callback"))

    {:ok, socket}
  end

  attr :indoor_token, Token
  attr :outdoor_token, Token

  def render(assigns) do
    ~H"""
    <article>
      <h3><%= gettext("Outdoor Sensors") %></h3>
      <%= if is_nil(@outdoor_token) do %>
        <.render_services services={@services.outdoor} redirect_uri={@redirect_uri} />
      <% else %>
        <.authorized_with location={:outdoor} token={@outdoor_token} myself={@myself} />
      <% end %>

      <h3><%= gettext("Indoor Sensors") %></h3>
      <%= if is_nil(@indoor_token) do %>
        <.render_services services={@services.indoor} redirect_uri={@redirect_uri} />
      <% else %>
        <.authorized_with location={:indoor} token={@indoor_token} myself={@myself} />
      <% end %>
    </article>
    """
  end

  def render_services(assigns) do
    ~H"""
    <ul>
      <%= for service <- @services do %>
        <li>
          <a href={service.authorize_link(@redirect_uri)}>
            <%= gettext("Authorize with") %> <%= display_name(service.name()) %>
          </a>
        </li>
      <% end %>
    </ul>
    """
  end

  def authorized_with(assigns) do
    ~H"""
    <p>
      <%= gettext("Authorized with") %> <%= display_name(@token.service) %>
    </p>
    <.button phx-click={"unauthorize-#{@location}"} phx-target={@myself}>
      <%= gettext("Unauthorize") %>
    </.button>
    """
  end

  def handle_event("unauthorize-outdoor", _, socket) do
    {:ok, _} = socket.assigns.outdoor_token |> Oauth.delete_token()
    {:noreply, assign(socket, :outdoor_token, nil)}
  end

  @spec display_name(atom) :: String.t()
  def display_name(service_name), do: service_name |> to_string() |> String.capitalize()
end

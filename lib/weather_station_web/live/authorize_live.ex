defmodule WeatherStationWeb.AuthorizeLive do
  use WeatherStationWeb, :live_view

  alias WeatherStation.TokenServer
  alias WeatherStation.Tempest

  require Logger

  def mount(_, session, socket) do
    id = Map.get(session, "session_id")

    outdoor_authorized = TokenServer.has_access_token?(:outdoor, id)
    indoor_authorized = TokenServer.has_access_token?(:indoor, id)

    socket =
      socket
      |> assign(:id, id)
      |> assign(:outdoor_authorized, outdoor_authorized)
      |> assign(:indoor_authorized, indoor_authorized)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h2>Outdoor Sensors</h2>
    <%= if @outdoor_authorized do %>
      <p>Authorized!</p>
    <% else %>
      <ul>
        <li>
          <a href={Tempest.authorize_link()}>Tempest</a>
        </li>
      </ul>
    <% end %>
    """
  end

  def handle_params(%{"code" => code, "state" => "outdoor:tempest"}, _uri, socket) do
    case TokenServer.fetch_access_token(:tempest, socket.assigns.id, code) do
      {:ok, token} ->
        Logger.info("[#{__MODULE__}] received Tempest token: #{token}")

        socket =
          socket
          |> put_flash(:info, "Successfully authorized Tempest")
          |> assign(:outdoor_authorized, true)
          |> push_patch(to: ~p"/authorize")

        {:noreply, socket}

      {:error, reason} ->
        Logger.warn("[#{__MODULE__}] received Tempest authentication error: #{inspect(reason)}")

        socket =
          socket
          |> put_flash(:error, "Something went wrong authorizing Tempest, please try again")
          |> push_patch(to: ~p"/authorize")

        {:noreply, socket}
    end
  end

  def handle_params(%{"code" => _code, "state" => "indoor:" <> _service}, _uri, socket) do
    # TODO: Handle indoor codes
    {:noreply, socket}
  end

  def handle_params(%{"code" => _code, "state" => state}, _uri, socket) do
    Logger.info("[#{__MODULE__}] Received a code for an unsupported service: #{state}")
    {:noreply, socket}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end
end

defmodule WeatherStationWeb.AuthorizeLive do
  use WeatherStationWeb, :live_view

  alias WeatherStation.Auth
  alias WeatherStation.Oauth.Tempest

  require Logger

  def render(assigns) do
    ~H"""
    <h2><%= gettext("Outdoor Sensors") %></h2>
    <%= if @outdoor_connection.status == :disconnected do %>
      <ul>
        <li>
          <a href={Tempest.authorize_link()}>
            <%= gettext("Authorize with Tempest") %>
          </a>
        </li>
      </ul>
    <% else %>
      <p>
        <%= authorized_text(@outdoor_connection.token) %>
        <.button phx-click="unauthorize-outdoor">
          <%= gettext("unauthorize") %>
        </.button>
      </p>
    <% end %>
    """
  end

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def handle_params(%{"code" => code, "state" => "outdoor:tempest"}, _uri, socket) do
    case Tempest.access_token(code) do
      {:ok, token} ->
        %{user_id: user_id} = socket.assigns

        {:ok, outdoor_token} =
          Auth.create_token(%{
            user_id: user_id,
            token: token,
            service: :tempest,
            location: :outdoor
          })

        Logger.info("Successfully stored outdoor:tempest token for user: #{user_id}")

        socket =
          socket
          |> put_flash(:info, "Successfully authorized Tempest")
          |> assign(:outdoor_token, outdoor_token)
          |> push_patch(to: ~p"/authorize")

        {:noreply, socket}

      {:error, reason} ->
        Logger.warning(
          "[#{__MODULE__}] received Tempest authentication error: #{inspect(reason)}"
        )

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

  def handle_event("unauthorize-outdoor", _, socket) do
    %{outdoor_connection: outdoor_connection} = socket.assigns

    {:ok, _} = outdoor_connection.token |> Auth.delete_token()

    outdoor_connection = outdoor_connection |> WeatherStation.Connection.disconnect()

    {:noreply, assign(socket, :outdoor_connection, outdoor_connection)}
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

defmodule WeatherStationWeb.AuthorizeLive do
  use WeatherStationWeb, :live_view

  alias WeatherStation.TokenServer
  alias WeatherStation.Tempest

  require Logger

  def mount(_, session, socket) do
    id = Map.get(session, "session_id")
    {:ok, assign(socket, :id, id)}
  end

  def render(assigns) do
    ~H"""
    <h2>Outdoor Sensors</h2>
    <ul>
      <li>
        <a href={Tempest.authorize_link()}>Tempest</a>
      </li>
    </ul>
    """
  end

  def handle_params(%{"code" => code, "state" => "outdoor:tempest"}, _uri, socket) do
    %{id: user_id} = socket.assigns

    thunk = fn -> Tempest.access_token(code) end

    socket =
      case TokenServer.fetch_access_token(user_id, :tempest, thunk) do
        {:error, reason} ->
          Logger.warn("[#{__MODULE__}] received Tempest authentication error: #{inspect(reason)}")

          socket
          |> put_flash(:error, "Something went wrong authorizing Tempest, please try again")

        {:ok, token} ->
          Logger.info("[#{__MODULE__}] received Tempest token: #{token}")

          socket
          |> put_flash(:info, "Successfully authorized Tempest")
      end

    {:noreply, push_patch(socket, to: ~p"/authorize")}
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

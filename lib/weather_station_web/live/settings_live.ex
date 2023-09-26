defmodule WeatherStationWeb.SettingsLive do
  use WeatherStationWeb, :live_view
  use WeatherStationWeb.StationConnection

  alias WeatherStationWeb.AuthorizeComponent

  require Logger

  def render(assigns) do
    ~H"""
    <main class="mx-auto mt-8 mb-0 flex max-w-3xl flex-col items-center gap-y-4">
      <h1>Settings</h1>
      <section>
        <h2><%= gettext("Authorize") %></h2>
        <.live_component
          module={AuthorizeComponent}
          id="authorize"
          outdoor_token={@outdoor_token}
          indoor_token={@indoor_token}
        />
      </section>
    </main>
    """
  end

  def mount(_, _, socket) do
    start_connection_heartbeat()
    {:ok, assign(socket, :redirect_uri, url(~p"/authorize/callback"))}
  end

  def handle_info(msg, socket) do
    Logger.info("[#{__MODULE__}] received unexpected message: #{inspect(msg)}")
    {:noreply, socket}
  end
end

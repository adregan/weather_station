defmodule WeatherStationWeb.WeatherStationComponents do
  use WeatherStationWeb, :html
  alias WeatherStation.Token

  attr :outdoor_connection, Token
  attr :indoor_connection, Token

  def weather_station_header(assigns) do
    ~H"""
    <header class="grid-cols-[max-content_1fr_max-content_max-content] grid w-screen gap-x-4 border-b-2 border-current">
      <.link navigate={~p"/"} class="flex items-center px-4">WS</.link>
      <div class="col-start-3 flex flex-col justify-center py-2">
        <.connection_status location={:outdoor} connection={@outdoor_connection} />
        <.connection_status location={:indoor} connection={@indoor_connection} />
      </div>

      <.link
        navigate={~p"/authorize"}
        class="col-start-4 flex items-center border-l border-solid border-l-current px-4 py-0"
      >
        <span class="hero-cog" role="img" aria-label="Update settings"></span>
      </.link>
    </header>
    """
  end

  attr :location, :atom, required: true
  attr :connection, WeatherStation.Connection, required: true

  defp connection_status(assigns) do
    ~H"""
    <div
      class="flex items-center gap-1"
      role="img"
      aria-label={"#{@location} status is #{@connection.status}"}
    >
      <span class="block">
        <%= case @location do
          :outdoor -> "🌳"
          :indoor -> "🏠"
        end %>
      </span>
      <span class={[
        case @connection.status do
          :pending -> "bg-yellow-300 animate-pulse"
          :disconnected -> "bg-red-400"
          :connected -> "bg-green-300"
        end,
        "block h-3 w-3 rounded-full"
      ]}>
      </span>
    </div>
    """
  end

  def weather_station_footer(assigns) do
    ~H"""
    <footer class="flex h-10 items-center justify-between border-t-2 border-solid border-current px-4">
      <p>
        <%= gettext("Authorize on another device by visiting: ") %> <%= url(~p"/code/#{@auth_code}") %>
      </p>
      <aside class="flex gap-4">
        <.footer_flash flash={@flash} kind={:info} />
        <.footer_flash flash={@flash} kind={:error} />
      </aside>
    </footer>
    """
  end

  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"

  def footer_flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      id={"flash-#{@kind}"}
      role="alert"
      phx-mounted={JS.transition("shake", time: 500)}
      phx-click={
        JS.push("lv:clear-flash", value: %{key: @kind})
        |> hide("#flash-#{@kind}")
      }
    >
      <p class="flex items-center gap-2">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4 bg-green-300" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4 bg-red-300" />
        <%= msg %>
      </p>
    </div>
    """
  end
end

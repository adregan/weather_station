defmodule WeatherStationWeb.WeatherStationComponents do
  use WeatherStationWeb, :html
  alias WeatherStation.Token

  # TODO: A struct to represent connections rather than just the token
  attr :indoor_token, Token
  attr :outdoor_token, Token

  def weather_station_header(assigns) do
    ~H"""
    <header class="flex w-screen items-center justify-center space-x-4 border-b-2 border-green-300 py-4">
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
      <.icon name="hero-face-smile" />
      <p>Connected: <%= @token.service %></p>
    <% else %>
      <.icon name="hero-face-frown" />
      <.link navigate={~p"/authorize"}>
        Authorize <%= @location |> to_string() |> String.capitalize() %> service
      </.link>
    <% end %>
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

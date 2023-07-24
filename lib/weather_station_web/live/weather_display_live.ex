defmodule WeatherStationWeb.WeatherDisplayLive do
  alias WeatherStationWeb.Header.HeaderComponent
  use WeatherStationWeb, :live_view

  def mount(_, _, socket) do
    if connected?(socket) do
      # TODO: Subscribe to pub sub for sensors
    end

    # TODO: Grab the connection states

    {:ok, assign(socket, indoor_connection: nil, outdoor_connection: nil)}
  end

  def render(assigns) do
    ~H"""
    <.live_component
      module={HeaderComponent}
      id="header"
      indoor_connection={@indoor_connection}
      outdoor_connection={@outdoor_connection}
    />
    <section>
      TODO: Station goes here
    </section>
    """
  end
end

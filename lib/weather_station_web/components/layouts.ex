defmodule WeatherStationWeb.Layouts do
  use WeatherStationWeb, :html
  import WeatherStationWeb.WeatherStationComponents

  embed_templates "layouts/*"
end

defmodule WeatherStationWeb.ErrorJSONTest do
  use WeatherStationWeb.ConnCase, async: true

  test "renders 404" do
    assert WeatherStationWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert WeatherStationWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end

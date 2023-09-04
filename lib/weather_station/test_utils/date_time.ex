defmodule WeatherStation.TestUtils.DateTime do
  def utc_now() do
    DateTime.new!(~D[2023-08-23], ~T[13:33:34], "Etc/UTC")
  end
end

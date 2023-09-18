defmodule WeatherStation.Test.Support.TimeTravelingClock do
  @mock_key String.to_atom("mock_utc_now:#{:rand.uniform(1000000)}")

  def utc_now do
    Application.get_env(:weather_station, @mock_key, DateTime.utc_now())
  end

  def freeze do
    Application.put_env(:weather_station, @mock_key, utc_now())
  end

  def freeze(%DateTime{} = on) do
    Application.put_env(:weather_station, @mock_key, on)
  end

  def unfreeze do
    Application.delete_env(:weather_station, :mock_utc_now)
  end
end

defmodule WeatherStation.AuthCode do
  def generate(len) when is_number(len) do
    :crypto.strong_rand_bytes(len)
    |> Base.url_encode64()
    |> binary_part(0, len)
  end
end

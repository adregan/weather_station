defmodule WeatherStation.Units do
  @type temp_unit :: :f | :c
  @spec convert_temperature(number(), temp_unit(), temp_unit()) ::
          number() | :error

  def convert_temperature(temp, :f, :c) when is_number(temp) do
    ((temp - 32) * 5 / 9) |> Float.round(1)
  end

  def convert_temperature(temp, :c, :f) when is_number(temp) do
    (temp * (9 / 5) + 32) |> Float.round(1)
  end

  def convert_temperature(temp, :c, :c) when is_number(temp), do: temp

  def convert_temperature(temp, :f, :f) when is_number(temp), do: temp

  def convert_temperature(temp, _, _) when is_number(temp), do: :error

  def convert_temperature(_, _, _), do: :error
end

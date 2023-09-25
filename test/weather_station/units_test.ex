defmodule WeatherStation.UnitsTest do
  use ExUnit.Case, async: true

  import WeatherStation.Units, only: [convert_temperature: 3]

  describe "convert_temperature/3" do
    test "returns :error when given unsupported units" do
      assert convert_temperature(12.3, :k, :f) == :error
      assert convert_temperature(12.3, :c, :k) == :error
    end

    test "returns :error when temp is not a number" do
      assert convert_temperature("12.8", :c, :f) == :error
    end

    test "converts Celsius into Fahrenheit" do
      assert convert_temperature(0, :c, :f) == 32
    end

    test "converts Fahrenheit into Celsius" do
      assert convert_temperature(65, :f, :c) == 18.3
    end
  end
end

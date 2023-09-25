defmodule WeatherStation.ObservationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeatherStation.Observations` context.
  """

  @doc """
  Generate a observation.
  """
  def observation_fixture(attrs \\ %{}) do
    {:ok, observation} =
      attrs
      |> Enum.into(%{
        data: %{}
      })
      |> WeatherStation.Observations.create_observation()

    observation
  end
end

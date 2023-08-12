defmodule WeatherStation.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeatherStation.Auth` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        token: "some token"
      })
      |> WeatherStation.Auth.create_token()

    token
  end
end

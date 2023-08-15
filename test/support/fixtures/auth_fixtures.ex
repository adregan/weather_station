defmodule WeatherStation.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeatherStation.Auth` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    user = WeatherStation.AccountsFixtures.user_fixture()

    {:ok, token} =
      attrs
      |> Enum.into(%{
        token: "some token",
        service: Enum.random([:tempest, :ecobee]),
        location: Enum.random([:indoor, :outdoor]),
        user_id: user.id
      })
      |> WeatherStation.Auth.create_token()

    token
  end
end

defmodule WeatherStation.TokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeatherStation.Tokens` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        service: :tempest,
        session_id: "7488a646-e31f-11e4-aace-600308960662",
        token: "some token"
      })
      |> WeatherStation.Tokens.create_token()

    token
  end
end

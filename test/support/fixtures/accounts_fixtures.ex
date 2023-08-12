defmodule WeatherStation.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeatherStation.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        auth_code: "some auth_code"
      })
      |> WeatherStation.Accounts.create_user()

    user
  end
end

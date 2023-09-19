defmodule WeatherStation.OauthTest do
  use WeatherStation.DataCase
  use Oban.Testing, repo: WeatherStation.Repo

  alias WeatherStation.Oauth

  setup do
    Oauth.subscribe()
    on_exit(fn -> Oauth.unsubscribe() end)
    :ok
  end

  describe "tokens" do
    alias WeatherStation.Oauth.Token

    import WeatherStation.OauthFixtures

    @invalid_attrs %{token: nil}

    test "list_tokens/0 returns all tokens" do
      token = token_fixture()
      assert Oauth.list_tokens() == [token]
    end

    test "get_token!/1 returns the token with given id" do
      token = token_fixture()
      assert Oauth.get_token!(token.id) == token
    end

    test "get_token_by_location/2 returns user's token with given location" do
      user = WeatherStation.AccountsFixtures.user_fixture()
      location = :outdoor
      token = token_fixture(%{user_id: user.id, location: location})

      assert Oauth.get_token_by_location(user, location) == token
    end

    test "get_token_by_location/2 returns nil if a token for a given location doesn't exist" do
      user = WeatherStation.AccountsFixtures.user_fixture()
      token = token_fixture(%{user_id: user.id, location: :outdoor})

      assert Oauth.get_token_by_location(user, :indoor) == nil
    end

    test "create_token/1 with valid data creates a token" do
      valid_attrs = %{
        token: "some token",
        location: :indoor,
        service: :ecobee
      }

      assert {:ok, %Token{} = token} = Oauth.create_token(valid_attrs)
      assert_received {:token_created, ^token}
      assert_enqueued(
        worker: WeatherStation.Workers.RefreshObservation,
        args: %{"token_id" => token.id},
        queue: :observations
      )
    end

    test "create_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Oauth.create_token(@invalid_attrs)
    end

    test "update_token/2 with valid data updates the token" do
      token = token_fixture()
      update_attrs = %{token: "some updated token"}

      assert {:ok, %Token{} = token} = Oauth.update_token(token, update_attrs)
      assert token.token == "some updated token"
      assert_received {:token_updated, ^token}
    end

    test "update_token/2 with invalid data returns error changeset" do
      token = token_fixture()
      assert {:error, %Ecto.Changeset{}} = Oauth.update_token(token, @invalid_attrs)
      assert token == Oauth.get_token!(token.id)
    end

    test "delete_token/1 deletes the token" do
      assert {:ok, %Token{} = token} =
               token_fixture() |> Oauth.delete_token()

      assert_raise Ecto.NoResultsError, fn -> Oauth.get_token!(token.id) end
      assert_received {:token_deleted, ^token}
      refute_enqueued(
        worker: WeatherStation.Workers.RefreshObservation,
        state: :scheduled,
        args: %{"token_id" => token.id}
      )
    end

    test "change_token/1 returns a token changeset" do
      token = token_fixture()
      assert %Ecto.Changeset{} = Oauth.change_token(token)
    end
  end
end

defmodule WeatherStation.TokensTest do
  use WeatherStation.DataCase

  alias WeatherStation.Tokens

  describe "tokens" do
    alias WeatherStation.Tokens.Token

    import WeatherStation.TokensFixtures

    @invalid_attrs %{service: nil, session_id: nil, token: nil}

    test "list_tokens/0 returns all tokens" do
      token = token_fixture()
      assert Tokens.list_tokens() == [token]
    end

    test "list_tokens/1 returns all tokens by session_id" do
      session_id = Ecto.UUID.generate()
      tokens = [
        token_fixture(%{ session_id: session_id }),
        token_fixture(%{ session_id: session_id, service: :ecobee }),
      ]
      assert Tokens.list_tokens(session_id) == tokens
    end

    test "list_tokens/2 returns all tokens by session_id and filter" do
      session_id = Ecto.UUID.generate()

      token_fixture(%{ session_id: session_id })
      indoor_token = token_fixture(%{ session_id: session_id, service: :ecobee })

      assert Tokens.list_tokens(session_id, %{type: :indoor}) == [indoor_token]
    end

    test "get_token!/1 returns the token with given id" do
      token = token_fixture()
      assert Tokens.get_token!(token.id) == token
    end

    test "create_token/1 with valid data creates a token" do
      valid_attrs = %{service: :tempest, session_id: "7488a646-e31f-11e4-aace-600308960662", token: "some token"}

      assert {:ok, %Token{} = token} = Tokens.create_token(valid_attrs)
      assert token.service == :tempest
      assert token.session_id == "7488a646-e31f-11e4-aace-600308960662"
      assert token.token == "some token"
    end

    test "create_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tokens.create_token(@invalid_attrs)
    end

    test "update_token/2 with valid data updates the token" do
      token = token_fixture()
      update_attrs = %{service: :ecobee, session_id: "7488a646-e31f-11e4-aace-600308960668", token: "some updated token"}

      assert {:ok, %Token{} = token} = Tokens.update_token(token, update_attrs)
      assert token.service == :ecobee
      assert token.session_id == "7488a646-e31f-11e4-aace-600308960668"
      assert token.token == "some updated token"
    end

    test "update_token/2 with invalid data returns error changeset" do
      token = token_fixture()
      assert {:error, %Ecto.Changeset{}} = Tokens.update_token(token, @invalid_attrs)
      assert token == Tokens.get_token!(token.id)
    end

    test "delete_token/1 deletes the token" do
      token = token_fixture()
      assert {:ok, %Token{}} = Tokens.delete_token(token)
      assert_raise Ecto.NoResultsError, fn -> Tokens.get_token!(token.id) end
    end

    test "change_token/1 returns a token changeset" do
      token = token_fixture()
      assert %Ecto.Changeset{} = Tokens.change_token(token)
    end
  end
end

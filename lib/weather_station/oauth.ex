defmodule WeatherStation.Oauth do
  @moduledoc """
  The Oauth context.
  """

  import Ecto.Query, warn: false
  alias WeatherStation.Repo

  alias WeatherStation.Oauth.Token

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(WeatherStation.PubSub, @topic)
  end

  def broadcast({:ok, token}, tag) do
    Phoenix.PubSub.broadcast(WeatherStation.PubSub, @topic, {tag, token})
    {:ok, token}
  end

  def broadcast({:error, _} = error, _), do: error

  @doc """
  Returns the list of tokens.

  ## Examples

      iex> list_tokens()
      [%Token{}, ...]

  """
  def list_tokens do
    Repo.all(Token)
  end

  @doc """
  Returns the list of tokens.
  """
  def list_tokens_by_user(user) do
    Token
    |> where(user_id: ^user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single token.

  Raises `Ecto.NoResultsError` if the Token does not exist.

  ## Examples

      iex> get_token!(123)
      %Token{}

      iex> get_token!(456)
      ** (Ecto.NoResultsError)

  """
  def get_token!(id), do: Repo.get!(Token, id)

  @doc """
  Creates a token.

  ## Examples

      iex> create_token(%{field: value})
      {:ok, %Token{}}

      iex> create_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:token_created)
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update_token(token, %{field: new_value})
      {:ok, %Token{}}

      iex> update_token(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_token(%Token{} = token, attrs) do
    token
    |> Token.changeset(attrs)
    |> Repo.update()
    |> broadcast(:token_updated)
  end

  @doc """
  Deletes a token.

  ## Examples

      iex> delete_token(token)
      {:ok, %Token{}}

      iex> delete_token(token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token(%Token{} = token) do
    Repo.delete(token)
    |> broadcast(:token_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking token changes.

  ## Examples

      iex> change_token(token)
      %Ecto.Changeset{data: %Token{}}

  """
  def change_token(%Token{} = token, attrs \\ %{}) do
    Token.changeset(token, attrs)
  end
end
defmodule WeatherStation.Tokens do
  @moduledoc """
  The Tokens context.
  """

  import Ecto.Query, warn: false
  alias WeatherStation.Repo

  alias WeatherStation.Tokens.Token

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
  Returns a list of tokens for the given user's session_id
  """
  def list_tokens(session_id, filter \\ %{}) when is_map(filter) do
    from(Token)
    |> where(session_id: ^session_id)
    |> filter_by_location(filter)
    |> Repo.all()
  end

  def filter_by_location(query, %{type: :outdoor}) do
    query |> where(service: :tempest)
  end

  def filter_by_location(query, %{type: :indoor}) do
    query |> where(service: :ecobee)
  end

  def filter_by_location(query, _), do: query

  def get_token_by_location(session_id, location) do
    from(Token)
    |> where(session_id: ^session_id)
    |> filter_by_location(%{type: location})
    |> Repo.one()
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

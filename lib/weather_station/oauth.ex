defmodule WeatherStation.Oauth do
  @moduledoc """
  The Oauth context.
  """

  import Ecto.Query, warn: false
  alias WeatherStation.Repo

  alias WeatherStation.Oauth.Token
  alias WeatherStation.Accounts.User

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(WeatherStation.PubSub, @topic)
  end

  def unsubscribe do
    Phoenix.PubSub.unsubscribe(WeatherStation.PubSub, @topic)
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

  @type location :: :outdoor | :indoor

  @spec get_token([{:id, String.t()}, {:user, User.t()}, {:location, location}]) ::
          Ecto.Schema.t() | term() | nil
  def get_token(opts \\ []) do
    opts |> Keyword.validate([:id, :user, :location])

    Token
    |> filter_by_id(Keyword.get(opts, :id))
    |> filter_by_user(Keyword.get(opts, :user))
    |> filter_by_location(Keyword.get(opts, :location))
    |> limit(1)
    |> Repo.one()
  end

  defp filter_by_id(query, id) when is_number(id), do: query |> where(id: ^id)
  defp filter_by_id(query, nil), do: query

  defp filter_by_user(query, %User{id: user_id}), do: query |> where(user_id: ^user_id)
  defp filter_by_user(query, nil), do: query

  defp filter_by_location(query, location) when is_atom(location) and not is_nil(location),
    do: query |> where(location: ^location)

  defp filter_by_location(query, nil), do: query

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
    |> enqueue_observation_job()
  end

  defp enqueue_observation_job({:ok, token}) do
    WeatherStation.Workers.RefreshObservation.enqueue(token)
    {:ok, token}
  end

  defp enqueue_observation_job({:error, _} = error), do: error

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
    |> dequeue_observation_job()
  end

  def dequeue_observation_job({:ok, token}) do
    WeatherStation.Workers.RefreshObservation.dequeue(token)
    {:ok, token}
  end

  def dequeue_observation_job({:error, _} = error), do: error

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

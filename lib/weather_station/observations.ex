defmodule WeatherStation.Observations do
  @moduledoc """
  The Observations context.
  """

  import Ecto.Query, warn: false
  alias WeatherStation.Oauth.Token
  alias WeatherStation.Repo

  alias WeatherStation.Observations.Observation

  @pubsub WeatherStation.PubSub
  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(WeatherStation.PubSub, @topic)
  end

  def unsubscribe do
    Phoenix.PubSub.unsubscribe(WeatherStation.PubSub, @topic)
  end

  def broadcast({:ok, observation}, tag) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, observation})
    {:ok, observation}
  end

  def broadcast({:error, _} = error, _), do: error

  @doc """
  Returns the list of observations.

  ## Examples

      iex> list_observations()
      [%Observation{}, ...]

  """
  def list_observations do
    Repo.all(Observation)
  end

  @doc """
  Gets a single observation.

  Raises `Ecto.NoResultsError` if the O observation does not exist.

  ## Examples

      iex> get_observation!(123)
      %Observation{}

      iex> get_observation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_observation!(id), do: Repo.get!(Observation, id)

  @spec get_latest_observation(Token.t()) :: Ecto.Schema.t() | term() | nil

  def get_latest_observation(%Token{id: token_id}) do
    Observation
    |> where(token_id: ^token_id)
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  def get_latest_observation(nil), do: nil

  @doc """
  Creates a observation.

  ## Examples

      iex> create_observation(%{field: value})
      {:ok, %Observation{}}

      iex> create_observation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_observation(attrs \\ %{}) do
    %Observation{}
    |> Observation.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:observation_created)
  end

  @doc """
  Updates a observation.

  ## Examples

      iex> update_observation(observation, %{field: new_value})
      {:ok, %Observation{}}

      iex> update_observation(observation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_observation(%Observation{} = observation, attrs) do
    observation
    |> Observation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a observation.

  ## Examples

      iex> delete_observation(observation)
      {:ok, %Observation{}}

      iex> delete_observation(observation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_observation(%Observation{} = observation) do
    Repo.delete(observation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking observation changes.

  ## Examples

      iex> change_observation(observation)
      %Ecto.Changeset{data: %Observation{}}

  """
  def change_observation(%Observation{} = observation, attrs \\ %{}) do
    Observation.changeset(observation, attrs)
  end
end

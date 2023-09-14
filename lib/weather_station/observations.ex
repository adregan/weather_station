defmodule WeatherStation.Observations do
  @moduledoc """
  The Observations Context.
  """
  require Logger

  alias WeatherStation.ObservationServer
  alias WeatherStation.Oauth.Token
  alias WeatherStation.Observations.{Observation, Tempest}

  @pubsub WeatherStation.PubSub
  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(WeatherStation.PubSub, @topic)
  end

  def broadcast({:ok, _} = observation, tag, user_id) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, user_id, observation})

    observation
  end

  def broadcast({:error, _} = error, tag, user_id) do
    case tag do
      :observation_created ->
        Phoenix.PubSub.broadcast(@pubsub, @topic, {:observation_errored, user_id, error})

      _ ->
        nil
    end

    error
  end

  def create_observation(%Token{user_id: user_id, location: location} = token) do
    Task.async(fn -> fetch_observation(token) end)
    |> Task.await()
    |> ObservationServer.insert(to_id(user_id, location))
    |> broadcast(:observation_created, user_id)
  end

  def get_observation(%Token{user_id: user_id, location: location} = token) do
    case ObservationServer.get(to_id(user_id, location)) do
      %Observation{} = observation -> {:ok, observation}

      nil ->
        create_observation(token)
        # TODO: Notify the jobs server that the token had no observations
    end
  end

  defp fetch_observation(%Token{service: service} = token) do
    case service do
      :tempest ->
        Tempest.fetch_observations(token)

      _ ->
        Logger.error("Fetching from service `#{service}` is not implemented")
        {:error, %{location: token.location, service: service, error_code: :not_implmented}}
    end
  end

  defp to_id(user_id, location), do: "#{user_id}:#{location}"
end

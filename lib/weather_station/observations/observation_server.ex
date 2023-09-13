defmodule WeatherStation.Observations.ObservationServer do
  use GenServer
  require Logger
  alias WeatherStation.Auth.Token
  alias WeatherStation.Observations.Tempest

  @server_name :observations
  @table_name :observation_table
  @refresh_rate :timer.minutes(1)
  @pubsub WeatherStation.PubSub
  @topic "observations"

  # Client
  def start_link(_) do
    refresh_refs = %{}
    GenServer.start_link(__MODULE__, refresh_refs, name: @server_name)
  end

  # TODO: Move pub sub code to context module
  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def latest_observation(%Token{user_id: user_id, location: location} = token) do
    case :ets.lookup(@table_name, storage_key(user_id, location)) do
      [{_, observation}] -> observation
      [] -> GenServer.call(@server_name, {:fetch_observation, token})
    end
  end

  # Server
  def init(refresh_refs) do
    :ets.new(@table_name, [:named_table])
    {:ok, refresh_refs}
  end

  def handle_call({:fetch_observation, %Token{} = token}, _, state) do
    {state, observation} = fetch_store_and_refresh(state, token)
    {:reply, observation, state}
  end

  def handle_info({:refresh, %Token{} = token}, state) do
    {state, _} = fetch_store_and_refresh(state, token)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("[#{__MODULE__}] received an unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  # TODO: Move pub sub code to context module?
  defp broadcast(user_id, observation) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {:new_observation, user_id, observation})
  end

  defp fetch_store_and_refresh(state, token) do
    key = storage_key(token.user_id, token.location)

    observation =
      fetch_observation(token)
      |> tap(&:ets.insert(@table_name, {key, &1}))
      |> tap(&broadcast(token.user_id, &1))

    # If @server_name is used instead of self(), the message will still be sent on a crash.
    # This can help recover if observer server goes down. However, if the station
    # is refreshed after the crash and before this message is sent, it is possible
    # to generate multiple zombie timers
    refresh_ref = Process.send_after(@server_name, {:refresh, token}, @refresh_rate)

    state = Map.put(state, key, refresh_ref)

    {state, observation}
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

  defp storage_key(user_id, location), do: user_id <> to_string(location)
end

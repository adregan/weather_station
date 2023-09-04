defmodule WeatherStation.Observations.ObservationServer do
  use GenServer
  require Logger
  alias WeatherStation.Auth.Token
  alias WeatherStation.Observations.FetchObservations

  @name :observations
  @refresh_rate :timer.minutes(1)
  @pubsub WeatherStation.PubSub
  @topic "observations"

  defmodule State do
    defstruct observations: %{}, refreshes: %{}

    def update(%State{} = state, path, data) do
      path
      |> Enum.map(&Access.key/1)
      |> (&put_in(state, &1, data)).()
    end

    def get(%State{} = state, path) do
      path
      |> Enum.map(&Access.key/1)
      |> (&get_in(state, &1)).()
    end

    def cached_or_update_with(%State{} = state, path, fun) do
      value =
        case State.get(state, path) do
          nil -> fun.()
          cached -> cached
        end

      State.update(state, path, value)
    end
  end

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  # TODO: Move pub sub code to context module
  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def latest_observations(%Token{} = token) do
    GenServer.call(@name, {:latest_observations, token})
  end

  # Server
  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call({:latest_observations, %Token{user_id: user_id} = token}, _, state) do
    state =
      state
      |> State.cached_or_update_with([:observations, user_id], fn ->
        fetch_observations(token)
      end)
      |> State.cached_or_update_with([:refreshes, user_id], fn ->
        schedule_refresh(token)
      end)

    observations = State.get(state, [:observations, user_id])

    broadcast(:observations, user_id, observations)

    {:reply, observations, state}
  end

  def handle_info({:refresh, %Token{user_id: user_id} = token}, state) do
    state
    |> State.update([:observations, user_id], fetch_observations(token))
    |> tap(fn state ->
      broadcast(:observations, user_id, State.get(state, [:observations, user_id]))
    end)
    |> State.update([:refreshes, user_id], schedule_refresh(token))
    |> then(&{:noreply, &1})
  end

  def handle_info(msg, state) do
    Logger.info("[#{__MODULE__}] received an unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end

  # TODO: Move pub sub code to context module
  defp broadcast(:observations, user_id, data) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {:observations_updated, user_id, data})
  end

  defp fetch_observations(%Token{} = token) do
    FetchObservations.with_token(token)
  end

  defp schedule_refresh(%Token{} = token) do
    # If @name is used instead of self(), the message will still be sent on a crash.
    # This can help recover if observer server goes down. However, if the station
    # is refreshed after the crash and before this message is sent, it is possible
    # to generate multiple zombie timers
    Process.send_after(@name, {:refresh, token}, @refresh_rate)
  end
end

defmodule WeatherStation.TokenServer do
  alias WeatherStation.Tempest
  use GenServer
  require Logger

  @name :token_server

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def has_access_token?(:outdoor, user_id) do
    GenServer.call(@name, {:outdoor, user_id})
  end

  def has_access_token?(:indoor, user_id) do
    GenServer.call(@name, {:indoor, user_id})
  end

  def fetch_access_token(:tempest, user_id, code) do
    GenServer.call(@name, {:tempest, user_id, code})
  end

  # Server
  def init(state), do: {:ok, state}

  def handle_call({:tempest, user_id, code}, _, state) do
    key = "#{user_id}:outdoor"
    case Map.get(state, key) do
      nil ->
        tempest_reply = Tempest.access_token(code)
        {:reply, tempest_reply, update_state(key, tempest_reply, state)}

      token ->
        {:reply, {:ok, token}, state}
    end
  end

  def handle_call({location, user_id}, _, state) do
    has_access_token =
      state
      |> Map.get("#{user_id}:#{location}")
      |> is_nil()
      |> Kernel.not()

    {:reply, has_access_token, state}
  end

  defp update_state(key, {:ok, token}, state) do
    Map.put(state, key, token)
  end

  defp update_state(_, {:error, _}, state), do: state
end

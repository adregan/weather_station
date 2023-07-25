defmodule WeatherStation.TokenServer do
  use GenServer
  require Logger

  @name :token_server

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def fetch_access_token(user_id, service, fetch_token_from_service) do
    GenServer.call(@name, {:fetch_access_token, user_id, service, fetch_token_from_service})
  end

  # Server
  def init(state), do: {:ok, state}

  def handle_call({:fetch_access_token, user_id, service, fetch_token_from_service}, _from, state) do
    key = "#{user_id}:#{service}"
    case Map.get(state, key) do
      nil ->
        reply = fetch_token_from_service.()
        {:reply, reply, update_state(key, reply, state)}

      token ->
        {:reply, {:ok, token}, state}
    end
  end

  defp update_state(key, {:ok, token}, state) do
    Map.put(state, key, token)
  end

  defp update_state(_, {:error, _}, state), do: state
end

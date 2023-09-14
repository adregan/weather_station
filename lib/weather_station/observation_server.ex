defmodule WeatherStation.ObservationServer do
  use GenServer
  require Logger
  alias WeatherStation.Observations.Observation

  @server_name :observations
  @table_name :observation_table

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, @table_name, name: @server_name)
  end

  def get(id) do
    case :ets.lookup(@table_name, id) do
      [{_, observation}] -> observation
      [] -> nil
    end
  end

  def insert({:ok, %Observation{} = observation}, key) do
    :ets.insert(@table_name, {key, observation})
    {:ok, observation}
  end

  def insert({:error, _} = error, _), do: error

  # Server
  def init(table_name) do
    table =
      :ets.new(table_name, [
        :set,
        :named_table,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])

    {:ok, table}
  end

  def handle_info(msg, state) do
    Logger.info("[#{__MODULE__}] received an unexpected message: #{inspect(msg)}")
    {:noreply, state}
  end
end

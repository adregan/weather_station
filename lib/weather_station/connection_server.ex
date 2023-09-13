defmodule WeatherStation.ConnectionServer do
  use GenServer
  alias WeatherStation.Connection
  alias WeatherStation.Auth.Token

  @server_name :connection_server
  @table_name :connections_table

  # Client
  def start_link(_) do
    GenServer.start_link(__MODULE__, @table_name, name: @server_name)
  end

  def get_connection(token, user_id, location) do
    key = storage_key(user_id, location)

    case :ets.lookup(@table_name, key) do
      [{_, connection}] -> connection
      [] -> create_connection(token, key)
    end
  end

  def create(%Token{user_id: user_id, location: location} = token) do
    create_connection(token, storage_key(user_id, location))
  end

  @spec update(%Connection{}, :connect | :degrade | :disconnect) :: %Connection{}

  def update(%Connection{token: token} = connection, :connect) do
    %{user_id: user_id, location: location} = token
    key = storage_key(user_id, location)

    connect(connection) |> store_connection(key)
  end

  def update(%Connection{token: token} = connection, :disconnect) do
    %{user_id: user_id, location: location} = token
    key = storage_key(user_id, location)

    disconnect(connection) |> store_connection(key)
  end

  def update(%Connection{status: :disconnected} = connection, :degrade) do
    connection
  end

  def update(%Connection{token: token} = connection, :degrade) do
    %{user_id: user_id, location: location} = token
    key = storage_key(user_id, location)

    degrade(connection) |> store_connection(key)
  end

  # Server
  def init(table_name) do
    table = :ets.new(table_name, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, table}
  end

  defp create_connection(token, key) do
    Connection.new(token) |> store_connection(key)
  end

  defp store_connection(%Connection{} = connection, key) do
    :ets.insert(@table_name, {key, connection})
    connection
  end

  defp connect(%Connection{} = connection) do
    Connection.connect(connection)
  end

  defp degrade(%Connection{status: status} = connection) do
    case status do
      status when status in [:pending, :degraded, :disconnected] ->
        Connection.disconnect(connection)
      :connected ->
        Connection.degrade(connection)
    end
  end

  defp disconnect(%Connection{} = connection) do
    Connection.disconnect(connection)
  end

  defp storage_key(user_id, location), do: user_id <> ":#{location}"
end

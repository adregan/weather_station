defmodule WeatherStation.Connection do
  defstruct status: :disconnected, token: nil, last_connected: nil

  @type status :: :disconnected | :connected | :pending

  @type t :: %__MODULE__{
          status: status,
          token:
            WeatherStation.Auth.Token.t()
            | nil,
          last_connected: DateTime.t() | nil
        }

  def new(%WeatherStation.Auth.Token{} = token) do
    %WeatherStation.Connection{
      status: :pending,
      token: token,
      last_connected: nil
    }
  end

  def new(nil), do: %WeatherStation.Connection{}

  def new, do: %WeatherStation.Connection{}

  def connect(%WeatherStation.Connection{} = connection) do
    %{connection | status: :connected, last_connected: DateTime.now!("Etc/UTC")}
  end

  def heart_beat(%WeatherStation.Connection{} = connection) do
    %{connection | last_connected: DateTime.now!("Etc/UTC")}
  end

  def disconnect(_) do
    WeatherStation.Connection.new()
  end
end

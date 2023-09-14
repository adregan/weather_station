defmodule WeatherStation.Connection do
  alias WeatherStation.Oauth.Token

  @date_time_adapter if Mix.env() == :test,
             do: WeatherStation.TestUtils.DateTime,
             else: DateTime

  defstruct status: :disconnected, token: nil, last_connected: nil

  @type status :: :disconnected | :connected | :pending | :degraded

  @type t :: %__MODULE__{
          status: status,
          token: Token.t() | nil,
          last_connected: DateTime.t() | nil
        }

  def new(%Token{} = token) do
    %WeatherStation.Connection{
      status: :pending,
      token: token,
      last_connected: nil
    }
  end

  def new(nil), do: %WeatherStation.Connection{status: :disconnected}

  def new, do: %WeatherStation.Connection{status: :disconnected}

  def connect(%WeatherStation.Connection{} = connection) do
    %{connection | status: :connected, last_connected: @date_time_adapter.utc_now()}
  end

  def disconnect(_), do: new()

  def degrade(%WeatherStation.Connection{} = connection) do
    %{connection | status: :degraded}
  end
end

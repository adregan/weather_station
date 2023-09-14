defmodule WeatherStation.WeatherSupervisor do
  use Supervisor
  require Logger

  def start_link(_) do
    Logger.info("Starting the supervisor #{__MODULE__}")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children =
      case Mix.env() do
        :test -> []
        _ -> [WeatherStation.ObservationServer, WeatherStation.ConnectionServer]
      end

    Supervisor.init(children, strategy: :one_for_one)
  end
end

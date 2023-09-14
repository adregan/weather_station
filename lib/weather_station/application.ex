defmodule WeatherStation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WeatherStationWeb.Telemetry,
      # Start the Ecto repository
      WeatherStation.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: WeatherStation.PubSub},
      # Start Finch
      {Finch, name: WeatherStation.Finch},
      # Start the Endpoint (http/https)
      WeatherStationWeb.Endpoint,
      # Start a worker by calling: WeatherStation.Worker.start_link(arg)
      # {WeatherStation.Worker, arg}
      WeatherStation.WeatherSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherStation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WeatherStationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

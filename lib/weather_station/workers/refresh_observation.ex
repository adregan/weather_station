defmodule WeatherStation.Workers.RefreshObservation do
  alias WeatherStation.Observations.Tempest
  use Oban.Worker, queue: :observations

  import Ecto.Query, only: [where: 2]
  import WeatherStation.Oauth, only: [get_token!: 1]

  alias WeatherStation.Observations
  alias WeatherStation.Oauth.Token

  @refresh_rate Application.compile_env(:weather_station, :refresh_rate_in_seconds)

  def enqueue(%Token{id: id}) do
    %{token_id: id}
    |> new()
    |> Oban.insert()
  end

  def dequeue(%Token{id: id}) do
    Oban.Job
    |> where(args: ^%{"token_id" => id})
    |> where(state: "scheduled")
    |> Oban.cancel_all_jobs()
  end

  @impl Oban.Worker
  def perform(%Job{args: %{"token_id" => token_id} = args, attempt: 1}) do
    args
    |> new(schedule_in: @refresh_rate)
    |> Oban.insert()

    observe(token_id)
  end

  def perform(%Job{args: %{"token_id" => token_id}}), do: observe(token_id)

  defp observe(token_id) do
    token = get_token!(token_id)

    case fetch(token) do
      {:ok, data} ->
        %{token_id: token_id, user_id: token.user_id, data: data}
        |> Observations.create_observation()

      error ->
        error
    end
  end

  defp fetch(%Token{service: :tempest} = token), do: Tempest.fetch_observation(token)
end

defmodule WeatherStation.Observations.Observation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  schema "observations" do
    field :data, :map
    field :user_id, :binary_id
    field :token_id, :id

    timestamps()
  end

  @doc false
  def changeset(observation, attrs) do
    observation
    |> cast(attrs, [:data, :user_id, :token_id])
    |> validate_required([:data])
  end
end

defmodule WeatherStation.Auth.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :token, :string
    field :user_id, :binary_id
    field :service, Ecto.Enum, values: [:tempest, :ecobee]
    field :location, Ecto.Enum, values: [:indoor, :outdoor]

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:token, :user_id, :service, :location])
    |> validate_required([:token, :user_id, :service, :location])
  end
end

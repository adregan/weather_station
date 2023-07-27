defmodule WeatherStation.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  @supported_services ~w(tempest ecobee)a

  schema "tokens" do
    field :service, Ecto.Enum, values: @supported_services
    field :session_id, Ecto.UUID
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:session_id, :service, :token])
    |> validate_required([:session_id, :service, :token])
  end
end

defmodule WeatherStation.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :auth_code, :string, autogenerate: {WeatherStation.AuthCode, :generate, [8]}
    field :session_key, Ecto.UUID, autogenerate: {Ecto.UUID, :generate, []}

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:auth_code, :session_key])
    |> validate_required([:auth_code, :session_key])
  end
end

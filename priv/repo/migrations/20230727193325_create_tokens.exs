defmodule WeatherStation.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :session_id, :uuid
      add :service, :string
      add :token, :string

      timestamps()
    end
  end
end

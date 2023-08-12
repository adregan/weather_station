defmodule WeatherStation.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :session_key, :uuid, null: false
      add :auth_code, :string, null: false

      timestamps()
    end
  end
end

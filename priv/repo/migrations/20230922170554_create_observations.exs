defmodule WeatherStation.Repo.Migrations.CreateObservations do
  use Ecto.Migration

  def change do
    create table(:observations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :data, :map
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :token_id, references(:tokens, on_delete: :nothing)

      timestamps()
    end

    create index(:observations, [:user_id])
    create index(:observations, [:token_id])
  end
end

defmodule WeatherStation.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :token, :string
      add :service, :string
      add :location, :string
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create index(:tokens, [:user_id])
    create index(:tokens, [:service])
  end
end

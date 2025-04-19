defmodule JetLagServer.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string, null: false
      add :status, :string, null: false, default: "waiting"
      add :started_at, :utc_datetime

      add :location_id, references(:locations, type: :binary_id, on_delete: :delete_all),
        null: false

      add :settings_id, references(:game_settings, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:games, [:code])
    create index(:games, [:location_id])
    create index(:games, [:settings_id])
  end
end

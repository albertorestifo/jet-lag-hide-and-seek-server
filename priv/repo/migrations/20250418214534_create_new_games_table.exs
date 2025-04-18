defmodule JetLagServer.Repo.Migrations.CreateNewGamesTable do
  use Ecto.Migration

  def change do
    # Drop existing tables if they exist
    drop_if_exists table(:locations)
    drop_if_exists table(:games)

    # Create the games table with osm_type and osm_id
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string, null: false
      add :status, :string, null: false, default: "waiting"
      add :started_at, :utc_datetime
      add :osm_type, :string, null: false
      add :osm_id, :string, null: false

      add :settings_id, references(:game_settings, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps()
    end

    # Create indexes
    create unique_index(:games, [:code])
    create index(:games, [:settings_id])
    create index(:games, [:osm_type, :osm_id])
  end
end

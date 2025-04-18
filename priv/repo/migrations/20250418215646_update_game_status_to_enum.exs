defmodule JetLagServer.Repo.Migrations.UpdateGameStatusToEnum do
  use Ecto.Migration

  def up do
    # For SQLite, we need to recreate the table to change column types
    # First, create a new table with the updated schema
    create table(:games_new, primary_key: false) do
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

    # Copy data from the old table to the new one
    # Convert string status values to atoms
    execute """
    INSERT INTO games_new (id, code, status, started_at, osm_type, osm_id, settings_id, inserted_at, updated_at)
    SELECT id, code, status, started_at, osm_type, osm_id, settings_id, inserted_at, updated_at FROM games
    """

    # Drop the old table
    drop table(:games)

    # Rename the new table to the original name
    rename table(:games_new), to: table(:games)

    # Recreate the indexes
    create unique_index(:games, [:code])
    create index(:games, [:settings_id])
    create index(:games, [:osm_type, :osm_id])
  end

  def down do
    # For SQLite, we need to recreate the table to change column types
    # First, create a new table with the original schema
    create table(:games_new, primary_key: false) do
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

    # Copy data from the current table to the new one
    # Convert atom status values back to strings
    execute """
    INSERT INTO games_new (id, code, status, started_at, osm_type, osm_id, settings_id, inserted_at, updated_at)
    SELECT id, code, status, started_at, osm_type, osm_id, settings_id, inserted_at, updated_at FROM games
    """

    # Drop the current table
    drop table(:games)

    # Rename the new table to the original name
    rename table(:games_new), to: table(:games)

    # Recreate the indexes
    create unique_index(:games, [:code])
    create index(:games, [:settings_id])
    create index(:games, [:osm_type, :osm_id])
  end
end

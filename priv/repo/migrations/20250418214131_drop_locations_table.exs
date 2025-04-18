defmodule JetLagServer.Repo.Migrations.DropLocationsTable do
  use Ecto.Migration

  def up do
    # SQLite doesn't support DROP CONSTRAINT, so we'll just drop the table
    # The foreign key will be removed in the next migration
    drop table(:locations)
  end

  def down do
    # Recreate the locations table
    create table(:locations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string
      add :coordinates, {:array, :float}, null: false
      add :bounding_box, {:array, :float}
      add :osm_id, :string
      add :osm_type, :string

      timestamps()
    end

    create index(:locations, [:name])

    # Add back the foreign key constraint
    alter table(:games) do
      modify :location_id, references(:locations, type: :binary_id, on_delete: :delete_all)
    end
  end
end

defmodule JetLagServer.Repo.Migrations.CreateCachedBoundaries do
  use Ecto.Migration

  def change do
    create table(:cached_boundaries) do
      add :osm_type, :string, null: false
      add :osm_id, :string, null: false
      add :data, :text, null: false

      timestamps()
    end

    create unique_index(:cached_boundaries, [:osm_type, :osm_id])
  end
end

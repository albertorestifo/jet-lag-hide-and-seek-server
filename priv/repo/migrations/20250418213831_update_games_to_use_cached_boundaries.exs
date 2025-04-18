defmodule JetLagServer.Repo.Migrations.UpdateGamesToUseCachedBoundaries do
  use Ecto.Migration

  def change do
    alter table(:games) do
      # Add new fields for cached boundary reference
      add :osm_type, :string
      add :osm_id, :string
    end

    # Create an index for faster lookups
    create index(:games, [:osm_type, :osm_id])
  end
end

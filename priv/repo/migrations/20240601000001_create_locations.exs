defmodule JetLagServer.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
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
  end
end

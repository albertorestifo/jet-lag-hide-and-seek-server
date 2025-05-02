defmodule JetLagServer.Repo.Migrations.CreatePlayerLocations do
  use Ecto.Migration

  def change do
    create table(:player_locations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :player_id, references(:players, type: :binary_id, on_delete: :delete_all), null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :precision, :float, null: false
      add :updated_at, :utc_datetime, null: false
    end

    create index(:player_locations, [:player_id])
  end
end

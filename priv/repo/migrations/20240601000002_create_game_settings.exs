defmodule JetLagServer.Repo.Migrations.CreateGameSettings do
  use Ecto.Migration

  def change do
    create table(:game_settings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :units, :string, null: false
      add :hiding_zones, {:array, :string}, null: false
      add :hiding_zone_size, :integer, null: false
      add :game_duration, :integer, null: false
      add :day_start_time, :string, null: false
      add :day_end_time, :string, null: false

      timestamps()
    end
  end
end

defmodule JetLagServer.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :is_creator, :boolean, default: false, null: false
      add :game_id, references(:games, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:players, [:game_id])
  end
end

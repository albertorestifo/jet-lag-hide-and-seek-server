defmodule JetLagServer.Repo.Migrations.AddGameSizeToGameSettings do
  use Ecto.Migration

  def change do
    # Add game_size column
    alter table(:game_settings) do
      add :game_size, :string, null: false, default: "medium"
    end

    # Create a function to update existing records
    execute """
    UPDATE game_settings
    SET game_size = CASE
      WHEN hiding_zone_size <= 250 THEN 'small'
      WHEN hiding_zone_size <= 600 THEN 'medium'
      ELSE 'large'
    END
    """

    # Remove hiding_zone_size column
    alter table(:game_settings) do
      remove :hiding_zone_size
    end
  end
end

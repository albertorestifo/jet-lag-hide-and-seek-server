defmodule JetLagServer.Games.GameSettings do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "game_settings" do
    field :units, :string
    field :hiding_zones, {:array, :string}
    field :hiding_zone_size, :integer
    field :game_duration, :integer
    field :day_start_time, :string
    field :day_end_time, :string

    timestamps()
  end

  @doc false
  def changeset(game_settings, attrs) do
    game_settings
    |> cast(attrs, [
      :units,
      :hiding_zones,
      :hiding_zone_size,
      :game_duration,
      :day_start_time,
      :day_end_time
    ])
    |> validate_required([
      :units,
      :hiding_zones,
      :hiding_zone_size,
      :game_duration,
      :day_start_time,
      :day_end_time
    ])
    |> validate_inclusion(:units, ["ansi", "iso"])
    |> validate_subset(:hiding_zones, [
      "bus_stops",
      "local_trains",
      "regional_trains",
      "high_speed_trains",
      "subways",
      "tram"
    ])
    |> validate_number(:hiding_zone_size,
      greater_than_or_equal_to: 100,
      less_than_or_equal_to: 2000
    )
    |> validate_number(:game_duration, greater_than_or_equal_to: 1)
    |> validate_format(:day_start_time, ~r/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    |> validate_format(:day_end_time, ~r/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
  end
end

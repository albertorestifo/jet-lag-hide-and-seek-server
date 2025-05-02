defmodule JetLagServer.Games.PlayerLocation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "player_locations" do
    field :latitude, :float
    field :longitude, :float
    field :precision, :float
    field :updated_at, :utc_datetime

    belongs_to :player, JetLagServer.Games.Player, type: :binary_id
  end

  @doc false
  def changeset(player_location, attrs) do
    player_location
    |> cast(attrs, [:player_id, :latitude, :longitude, :precision, :updated_at])
    |> validate_required([:player_id, :latitude, :longitude, :precision, :updated_at])
    |> validate_number(:latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
    |> validate_number(:precision, greater_than: 0)
    |> foreign_key_constraint(:player_id)
  end
end

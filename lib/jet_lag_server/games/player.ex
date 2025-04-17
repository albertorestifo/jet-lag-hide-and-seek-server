defmodule JetLagServer.Games.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "players" do
    field :name, :string
    field :is_creator, :boolean, default: false
    
    belongs_to :game, JetLagServer.Games.Game, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :is_creator, :game_id])
    |> validate_required([:name])
  end
end

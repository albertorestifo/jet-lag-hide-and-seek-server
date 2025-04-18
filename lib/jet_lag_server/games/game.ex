defmodule JetLagServer.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  # Define the game status enum
  @game_statuses [:waiting, :active, :completed]

  schema "games" do
    field :code, :string
    field :status, Ecto.Enum, values: @game_statuses, default: :waiting
    field :started_at, :utc_datetime, default: nil
    field :osm_type, :string
    field :osm_id, :string

    belongs_to :settings, JetLagServer.Games.GameSettings, type: :binary_id
    has_many :players, JetLagServer.Games.Player

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :status, :started_at, :osm_type, :osm_id, :settings_id])
    |> validate_required([:code, :status, :osm_type, :osm_id])
    |> validate_format(:code, ~r/^[A-Z0-9]{6}$/)
    |> unique_constraint(:code)
  end

  @doc """
  Generates a random 6-character game code.
  """
  def generate_code do
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    code_length = 6

    1..code_length
    |> Enum.map(fn _ -> String.at(chars, :rand.uniform(String.length(chars)) - 1) end)
    |> Enum.join("")
  end
end

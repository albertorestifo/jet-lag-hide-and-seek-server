defmodule JetLagServer.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "games" do
    field :code, :string
    field :status, :string, default: "waiting"
    field :started_at, :utc_datetime, default: nil
    
    belongs_to :location, JetLagServer.Games.Location, type: :binary_id
    belongs_to :settings, JetLagServer.Games.GameSettings, type: :binary_id
    has_many :players, JetLagServer.Games.Player

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :status, :started_at, :location_id, :settings_id])
    |> validate_required([:code, :status])
    |> validate_format(:code, ~r/^[A-Z0-9]{6}$/)
    |> validate_inclusion(:status, ["waiting", "active", "completed"])
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

defmodule JetLagServerWeb.Schemas.Player do
  @moduledoc """
  Schema for a player.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Player",
    description: "A player in the game",
    type: :object,
    required: [:id, :name],
    properties: %{
      id: %Schema{
        type: :string,
        description: "Unique identifier for the player",
        example: "player-123"
      },
      name: %Schema{type: :string, description: "Player's name", example: "John Doe"},
      is_creator: %Schema{
        type: :boolean,
        description: "Whether this player created the game",
        default: false,
        example: true
      }
    }
  })
end

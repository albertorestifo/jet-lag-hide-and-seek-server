defmodule JetLagServerWeb.Schemas.Game do
  @moduledoc """
  Schema for a game.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema
  alias JetLagServerWeb.Schemas.{Location, GameSettings, Player}

  OpenApiSpex.schema(%{
    title: "Game",
    description: "A hide and seek game",
    type: :object,
    required: [:id, :code, :location, :settings, :players, :status],
    properties: %{
      id: %Schema{
        type: :string,
        description: "Unique identifier for the game",
        example: "game-123"
      },
      code: %Schema{
        type: :string,
        description: "Short code for joining the game",
        pattern: "^[A-Z0-9]{6}$",
        example: "ABC123"
      },
      location: %Schema{
        allOf: [Location],
        description: "Location of the game"
      },
      settings: %Schema{
        allOf: [GameSettings],
        description: "Settings for the game"
      },
      players: %Schema{
        type: :array,
        description: "Players in the game",
        items: %Schema{allOf: [Player]}
      },
      status: %Schema{
        type: :string,
        enum: ["waiting", "active", "completed"],
        description: "Current status of the game",
        example: "waiting"
      },
      created_at: %Schema{
        type: :string,
        format: :date_time,
        description: "When the game was created",
        example: "2023-06-15T14:30:00Z"
      },
      started_at: %Schema{
        type: :string,
        format: :date_time,
        description: "When the game was started",
        nullable: true,
        example: nil
      }
    }
  })
end

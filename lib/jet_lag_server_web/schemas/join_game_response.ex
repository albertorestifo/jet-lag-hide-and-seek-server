defmodule JetLagServerWeb.Schemas.JoinGameResponse do
  @moduledoc """
  Schema for joining a game response.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema
  alias JetLagServerWeb.Schemas.Game

  OpenApiSpex.schema(%{
    title: "JoinGameResponse",
    description: "Response after joining a game",
    type: :object,
    required: [:game_id, :player_id, :websocket_url, :game],
    properties: %{
      game_id: %Schema{
        type: :string,
        description: "ID of the joined game",
        example: "game-123"
      },
      player_id: %Schema{
        type: :string,
        description: "ID assigned to the player",
        example: "player-456"
      },
      websocket_url: %Schema{
        type: :string,
        description: "WebSocket URL for real-time updates",
        example: "wss://api.jetlag.example.com/ws/games/game-123"
      },
      game: %Schema{
        allOf: [Game],
        description: "The game that was joined"
      }
    }
  })
end

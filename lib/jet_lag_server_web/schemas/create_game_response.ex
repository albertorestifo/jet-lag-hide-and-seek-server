defmodule JetLagServerWeb.Schemas.CreateGameResponse do
  @moduledoc """
  Schema for creating a game response.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CreateGameResponse",
    description: "Response after creating a game",
    type: :object,
    required: [:game_id, :game_code, :websocket_url],
    properties: %{
      game_id: %Schema{
        type: :string,
        description: "Unique identifier for the created game",
        example: "game-123"
      },
      game_code: %Schema{
        type: :string,
        description: "Short code for joining the game",
        example: "ABC123"
      },
      websocket_url: %Schema{
        type: :string,
        description: "WebSocket URL for real-time updates",
        example: "wss://api.jetlag.example.com/ws/games/game-123"
      }
    }
  })
end

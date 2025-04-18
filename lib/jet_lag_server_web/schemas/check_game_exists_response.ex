defmodule JetLagServerWeb.Schemas.CheckGameExistsResponse do
  @moduledoc """
  Schema for checking if a game exists response.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "CheckGameExistsResponse",
    description: "Response after checking if a game exists",
    type: :object,
    required: [:exists],
    properties: %{
      exists: %Schema{
        type: :boolean,
        description: "Whether the game exists",
        example: true
      },
      game_id: %Schema{
        type: :string,
        description: "ID of the game if it exists",
        example: "game-123",
        nullable: true
      }
    }
  })
end

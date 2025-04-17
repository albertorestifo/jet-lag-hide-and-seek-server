defmodule JetLagServerWeb.Schemas.JoinGameRequest do
  @moduledoc """
  Schema for joining a game request.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "JoinGameRequest",
    description: "Request to join an existing game",
    type: :object,
    required: [:game_code, :player_name],
    properties: %{
      game_code: %Schema{
        type: :string,
        description: "Code for the game to join",
        example: "ABC123"
      },
      player_name: %Schema{
        type: :string,
        description: "Name of the player joining",
        example: "Jane Smith"
      }
    }
  })
end

defmodule JetLagServerWeb.Schemas.CreateGameRequest do
  @moduledoc """
  Schema for creating a game request.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema
  alias JetLagServerWeb.Schemas.{Location, GameSettings}

  OpenApiSpex.schema(%{
    title: "CreateGameRequest",
    description: "Request to create a new game",
    type: :object,
    required: [:location, :settings, :creator],
    properties: %{
      location: %Schema{
        allOf: [Location],
        description: "Location of the game"
      },
      settings: %Schema{
        allOf: [GameSettings],
        description: "Settings for the game"
      },
      creator: %Schema{
        type: :object,
        required: [:name],
        properties: %{
          name: %Schema{
            type: :string,
            description: "Name of the player creating the game",
            example: "John Doe"
          }
        }
      }
    }
  })
end

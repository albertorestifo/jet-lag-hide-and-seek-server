defmodule JetLagServerWeb.Schemas.CreateGameRequest do
  @moduledoc """
  Schema for creating a game request.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema
  alias JetLagServerWeb.Schemas.GameSettings

  OpenApiSpex.schema(%{
    title: "CreateGameRequest",
    description: "Request to create a new game",
    type: :object,
    required: [:location_id, :settings, :creator],
    properties: %{
      location_id: %Schema{
        type: :string,
        description: "ID of the location in format 'osm_type:osm_id'",
        example: "way:123456"
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

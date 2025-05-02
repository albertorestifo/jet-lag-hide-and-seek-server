defmodule JetLagServerWeb.Schemas.PlayerLocation do
  @moduledoc """
  Schema for a player's location.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "PlayerLocation",
    description: "A player's location",
    type: :object,
    required: [:latitude, :longitude, :precision, :updated_at],
    properties: %{
      latitude: %Schema{
        type: :number,
        format: :float,
        description: "Latitude coordinate",
        minimum: -90,
        maximum: 90,
        example: 40.4168
      },
      longitude: %Schema{
        type: :number,
        format: :float,
        description: "Longitude coordinate",
        minimum: -180,
        maximum: 180,
        example: -3.7038
      },
      precision: %Schema{
        type: :number,
        format: :float,
        description: "Precision of the location in meters",
        minimum: 0,
        example: 10.0
      },
      updated_at: %Schema{
        type: :string,
        format: :date_time,
        description: "When the location was last updated",
        example: "2023-06-15T14:30:00Z"
      }
    }
  })
end

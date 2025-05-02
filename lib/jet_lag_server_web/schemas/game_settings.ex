defmodule JetLagServerWeb.Schemas.GameSettings do
  @moduledoc """
  Schema for game settings.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "GameSettings",
    description: "Settings for a game",
    type: :object,
    required: [
      :units,
      :game_size,
      :hiding_zones,
      :game_duration,
      :day_start_time,
      :day_end_time
    ],
    properties: %{
      units: %Schema{
        type: :string,
        enum: ["ansi", "iso"],
        description: "Unit system to use",
        example: "iso"
      },
      game_size: %Schema{
        type: :string,
        enum: ["small", "medium", "large"],
        description: "Size of the game (S|M|L)",
        example: "medium"
      },
      hiding_zones: %Schema{
        type: :array,
        description: "Types of locations where players can hide",
        items: %Schema{
          type: :string,
          enum: [
            "bus_stops",
            "local_trains",
            "regional_trains",
            "high_speed_trains",
            "subways",
            "tram"
          ]
        },
        example: ["bus_stops", "local_trains"]
      },
      game_duration: %Schema{
        type: :integer,
        description: "Duration of the game in days",
        minimum: 1,
        example: 1
      },
      day_start_time: %Schema{
        type: :string,
        description: "Daily start time in HH:MM format",
        pattern: "^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$",
        example: "09:00"
      },
      day_end_time: %Schema{
        type: :string,
        description: "Daily end time in HH:MM format",
        pattern: "^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$",
        example: "18:00"
      }
    }
  })
end

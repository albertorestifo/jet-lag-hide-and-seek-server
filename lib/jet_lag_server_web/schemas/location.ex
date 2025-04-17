defmodule JetLagServerWeb.Schemas.Location do
  @moduledoc """
  Schema for a location.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Location",
    description: "A location in the game",
    type: :object,
    required: [:name, :coordinates],
    properties: %{
      name: %Schema{type: :string, description: "Name of the location", example: "Madrid"},
      type: %Schema{
        type: :string,
        description: "Type of location (city, region, country)",
        example: "City"
      },
      coordinates: %Schema{
        type: :array,
        description: "Longitude and latitude coordinates",
        items: %Schema{type: :number},
        minItems: 2,
        maxItems: 2,
        example: [-3.7038, 40.4168]
      },
      bounding_box: %Schema{
        type: :array,
        description: "Bounding box coordinates [minLon, minLat, maxLon, maxLat]",
        items: %Schema{type: :number},
        minItems: 4,
        maxItems: 4,
        example: [-3.8, 40.3, -3.6, 40.5]
      },
      osm_id: %Schema{type: :string, description: "OpenStreetMap ID", example: "12345678"},
      osm_type: %Schema{
        type: :string,
        description: "OpenStreetMap element type",
        example: "way"
      }
    }
  })
end

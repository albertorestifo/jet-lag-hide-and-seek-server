defmodule JetLagServerWeb.Schemas.LocationBoundaries do
  @moduledoc """
  Schema for location boundaries.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "LocationBoundaries",
    description: "Boundaries of a location",
    type: :object,
    required: [:name, :osm_id, :osm_type],
    properties: %{
      name: %Schema{
        type: :string,
        description: "Name of the location",
        example: "Madrid"
      },
      type: %Schema{
        type: :string,
        description: "Type of location",
        enum: ["country", "state", "city", "other"],
        example: "city"
      },
      osm_id: %Schema{
        type: :string,
        description: "OpenStreetMap ID",
        example: "123456"
      },
      osm_type: %Schema{
        type: :string,
        description: "OpenStreetMap element type",
        example: "way"
      },
      coordinates: %Schema{
        type: :array,
        description: "Centroid coordinates [longitude, latitude]",
        items: %Schema{type: :number},
        minItems: 2,
        maxItems: 2,
        example: [-3.7038, 40.4168]
      },
      boundaries: %Schema{
        type: :object,
        description: "GeoJSON representation of the boundaries",
        additionalProperties: true
      }
    }
  })
end

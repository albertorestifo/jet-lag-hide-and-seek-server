defmodule JetLagServerWeb.Schemas.LocationSearchResult do
  @moduledoc """
  Schema for location search results.
  """
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "LocationSearchResult",
    description: "A location search result",
    type: :object,
    required: [:id, :title, :subtitle],
    properties: %{
      id: %Schema{
        type: :string,
        description: "Unique identifier for the location (format: osm_type:osm_id)",
        example: "way:123456"
      },
      title: %Schema{
        type: :string,
        description: "Name of the location",
        example: "Madrid"
      },
      subtitle: %Schema{
        type: :string,
        description: "Type of location (Country, State, City)",
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
      type: %Schema{
        type: :string,
        description: "Location type",
        enum: ["country", "state", "city"],
        example: "city"
      }
    }
  })
end

defmodule JetLagServerWeb.API.GeocodingController do
  use JetLagServerWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias JetLagServer.Geocoding
  alias JetLagServerWeb.Schemas
  alias OpenApiSpex.Schema

  action_fallback JetLagServerWeb.FallbackController

  tags(["geocoding"])

  operation(:autocomplete,
    summary: "Search for locations",
    description: "Returns a list of locations matching the search query",
    parameters: [
      query: [
        in: :query,
        description: "Search query",
        type: :string,
        example: "Madrid",
        required: true
      ],
      limit: [
        in: :query,
        description: "Maximum number of results to return",
        type: :integer,
        example: 10,
        required: false
      ],
      lang: [
        in: :query,
        description: "Language for results",
        type: :string,
        example: "en",
        required: false
      ]
    ],
    responses: [
      ok:
        {"Location search results", "application/json",
         %Schema{
           type: :object,
           properties: %{
             data: %Schema{
               type: :array,
               items: Schemas.LocationSearchResult
             }
           }
         }},
      bad_request: {"Invalid request", "application/json", Schemas.Error},
      internal_server_error: {"Server error", "application/json", Schemas.Error}
    ]
  )

  def autocomplete(conn, %{"query" => query} = params) do
    limit = Map.get(params, "limit", "10") |> String.to_integer()
    lang = Map.get(params, "lang", "en")

    case Geocoding.search_locations(query, limit: limit, lang: lang) do
      {:ok, locations} ->
        # Structs are automatically encoded to JSON by Jason
        json(conn, %{data: locations})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: %{code: "search_failed", message: reason}})
    end
  end

  operation(:boundaries,
    summary: "Get location boundaries",
    description: "Returns the boundaries of a location by its ID",
    parameters: [
      id: [
        in: :path,
        description: "Location ID (format: osm_type:osm_id)",
        type: :string,
        example: "way:123456",
        required: true
      ]
    ],
    responses: [
      ok:
        {"Location boundaries", "application/json",
         %Schema{
           type: :object,
           properties: %{
             data: Schemas.LocationBoundaries
           }
         }},
      bad_request: {"Invalid request", "application/json", Schemas.Error},
      not_found: {"Location not found", "application/json", Schemas.Error},
      internal_server_error: {"Server error", "application/json", Schemas.Error}
    ]
  )

  def boundaries(conn, %{"id" => id}) do
    case String.split(id, ":") do
      [osm_type, osm_id] ->
        case Geocoding.get_location_boundaries(osm_type, osm_id) do
          {:ok, boundary} ->
            # Struct is automatically encoded to JSON by Jason
            json(conn, %{data: boundary})

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: %{code: "boundaries_fetch_failed", message: reason}})
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          error: %{
            code: "invalid_id",
            message: "Invalid location ID format. Expected format: osm_type:osm_id"
          }
        })
    end
  end
end

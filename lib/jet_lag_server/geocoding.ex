defmodule JetLagServer.Geocoding do
  @moduledoc """
  Handles geocoding operations using external APIs.
  """

  alias JetLagServer.Geocoding.{Photon, OpenStreetMap, CachedBoundary}
  alias JetLagServer.Geocoding.Structs.{Location, Boundary}
  alias JetLagServer.Repo

  @doc """
  Searches for locations matching the given query.

  Returns a list of Location structs with title, subtitle, and ID.
  Only returns countries, regions/states, and cities.

  ## Options

  * `:limit` - Maximum number of results to return (default: 10)
  * `:lang` - Language for results (default: "en")
  * `:layers` - List of location types to include (default: ["country", "state", "city"])
  """
  @spec search_locations(String.t(), Keyword.t()) :: {:ok, [Location.t()]} | {:error, String.t()}
  def search_locations(query, opts \\ []) do
    # Ensure layers are always set to our default if not provided
    opts = Keyword.put_new(opts, :layers, ["country", "state", "city"])
    Photon.search(query, opts)
  end

  @doc """
  Gets the boundaries of a location by its ID.

  Returns a Boundary struct with the location details including boundaries.
  Uses cache if available, otherwise fetches from OpenStreetMap.
  """
  @spec get_location_boundaries(String.t(), String.t()) ::
          {:ok, Boundary.t()} | {:error, String.t()}
  def get_location_boundaries(osm_type, osm_id) do
    # Check if boundaries are in cache
    case Repo.get_by(CachedBoundary, osm_type: osm_type, osm_id: osm_id) do
      nil ->
        # Not in cache, fetch from OpenStreetMap
        case OpenStreetMap.get_boundaries(osm_type, osm_id) do
          {:ok, boundary} ->
            # Store in cache for future use
            store_boundary(osm_type, osm_id, boundary)
            {:ok, boundary}

          error ->
            error
        end

      cached ->
        # Return from cache
        cached_data = Jason.decode!(cached.data)
        boundary = struct(Boundary, Map.new(cached_data, fn {k, v} -> {String.to_atom(k), v} end))
        {:ok, boundary}
    end
  end

  # Store boundary in the database
  defp store_boundary(osm_type, osm_id, boundary) do
    data = Jason.encode!(boundary)

    %CachedBoundary{}
    |> CachedBoundary.changeset(%{
      osm_type: osm_type,
      osm_id: osm_id,
      data: data
    })
    |> Repo.insert(
      on_conflict: [set: [data: data]],
      conflict_target: [:osm_type, :osm_id]
    )
  end
end

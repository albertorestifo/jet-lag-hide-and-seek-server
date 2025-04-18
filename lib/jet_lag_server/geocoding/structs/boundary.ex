defmodule JetLagServer.Geocoding.Structs.Boundary do
  @moduledoc """
  Struct representing location boundaries from the OpenStreetMap API.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          osm_id: String.t(),
          osm_type: String.t(),
          bounding_box: [float()] | nil,
          coordinates: [float()] | nil,
          boundaries: map() | nil
        }

  @derive {Jason.Encoder, only: [:name, :type, :osm_id, :osm_type, :bounding_box, :coordinates, :boundaries]}
  defstruct [
    :name,
    :type,
    :osm_id,
    :osm_type,
    :bounding_box,
    :coordinates,
    :boundaries
  ]

  @doc """
  Creates a new Boundary struct from OpenStreetMap API response data.
  """
  @spec from_osm_response(map(), String.t(), String.t()) :: t()
  def from_osm_response(data, osm_type, osm_id) do
    # Extract the relevant information
    name = get_in(data, ["localname"])
    type = get_location_type(data)
    
    # Get the bounding box
    bounding_box = get_in(data, ["boundingbox"])
    |> parse_bounding_box()
    
    # Get the GeoJSON for the boundaries
    boundaries = get_in(data, ["geometry"])
    
    # Get the centroid coordinates
    centroid = get_centroid(data)
    
    %__MODULE__{
      name: name,
      type: type,
      osm_id: osm_id,
      osm_type: osm_type,
      bounding_box: bounding_box,
      coordinates: centroid,
      boundaries: boundaries
    }
  end

  # Parse the bounding box from the API response
  defp parse_bounding_box(nil), do: nil
  defp parse_bounding_box([south, north, west, east]) do
    [
      String.to_float(west),
      String.to_float(south),
      String.to_float(east),
      String.to_float(north)
    ]
  end
  
  # Get the centroid coordinates from the API response
  defp get_centroid(data) do
    case get_in(data, ["centroid", "coordinates"]) do
      [lon, lat] -> [lon, lat]
      _ -> nil
    end
  end
  
  # Determine the location type from the API response
  defp get_location_type(data) do
    address = get_in(data, ["address"]) || %{}
    
    cond do
      Map.has_key?(address, "country") && !Map.has_key?(address, "state") && !Map.has_key?(address, "city") ->
        "country"
      Map.has_key?(address, "state") && !Map.has_key?(address, "city") ->
        "state"
      Map.has_key?(address, "city") ->
        "city"
      true ->
        "other"
    end
  end
end

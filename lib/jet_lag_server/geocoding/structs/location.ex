defmodule JetLagServer.Geocoding.Structs.Location do
  @moduledoc """
  Struct representing a location from the Photon API.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          subtitle: String.t(),
          coordinates: [float()],
          osm_id: String.t(),
          osm_type: String.t(),
          type: String.t()
        }

  @derive {Jason.Encoder, only: [:id, :title, :subtitle, :coordinates, :osm_id, :osm_type, :type]}
  defstruct [
    :id,
    :title,
    :subtitle,
    :coordinates,
    :osm_id,
    :osm_type,
    :type
  ]

  @doc """
  Creates a new Location struct from Photon API feature data.
  """
  @spec from_photon_feature(map()) :: t()
  def from_photon_feature(feature) do
    properties = Map.get(feature, "properties", %{})
    geometry = Map.get(feature, "geometry", %{})
    coordinates = Map.get(geometry, "coordinates", [0, 0])

    type = get_location_type(properties)
    name = get_location_name(properties, type)
    osm_id = Map.get(properties, "osm_id")
    osm_type = Map.get(properties, "osm_type")

    %__MODULE__{
      id: "#{osm_type}:#{osm_id}",
      title: name,
      subtitle: String.capitalize(type),
      coordinates: coordinates,
      osm_id: osm_id,
      osm_type: osm_type,
      type: type
    }
  end

  # Determine the location type from properties
  defp get_location_type(properties) do
    osm_value = Map.get(properties, "osm_value")
    osm_key = Map.get(properties, "osm_key")

    cond do
      # Check for country
      osm_value == "country" ||
          (Map.get(properties, "country") != nil && Map.get(properties, "city") == nil &&
             Map.get(properties, "state") == nil) ->
        "country"

      # Check for state/region
      osm_value == "state" || osm_value == "region" ||
          (Map.get(properties, "state") != nil && Map.get(properties, "city") == nil) ->
        "state"

      # Check for city
      osm_value == "city" || osm_value == "town" || osm_key == "place" ||
          Map.get(properties, "city") != nil ->
        "city"

      true ->
        "other"
    end
  end

  # Get the appropriate name for the location based on its type
  defp get_location_name(properties, "country") do
    Map.get(properties, "country")
  end

  defp get_location_name(properties, "state") do
    Map.get(properties, "state")
  end

  defp get_location_name(properties, "city") do
    Map.get(properties, "city")
  end

  defp get_location_name(properties, _) do
    Map.get(properties, "name")
  end
end

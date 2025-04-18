defmodule JetLagServer.Geocoding.OpenStreetMap do
  @moduledoc """
  Client for the OpenStreetMap API to fetch location boundaries.
  """

  alias JetLagServer.Geocoding.Structs.Boundary

  @base_url "https://nominatim.openstreetmap.org"
  @user_agent "JetLagHideAndSeekApp/1.0"

  @doc """
  Gets the boundaries of a location by its OSM type and ID.

  Returns a Boundary struct with the location details including boundaries.
  """
  @spec get_boundaries(String.t(), String.t()) :: {:ok, Boundary.t()} | {:error, String.t()}
  def get_boundaries(osm_type, osm_id) do
    url =
      "#{@base_url}/details.php?osmtype=#{String.upcase(String.at(osm_type, 0))}&osmid=#{osm_id}&class=boundary&format=json&polygon_geojson=1"

    headers = [
      {"User-Agent", @user_agent},
      {"Accept", "application/json"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_boundaries_response(body, osm_type, osm_id)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "OpenStreetMap API returned status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error calling OpenStreetMap API: #{reason}"}
    end
  end

  # Parse the OpenStreetMap API response
  defp parse_boundaries_response(body, osm_type, osm_id) do
    case Jason.decode(body) do
      {:ok, data} ->
        boundary = Boundary.from_osm_response(data, osm_type, osm_id)
        {:ok, boundary}

      {:error, _} ->
        {:error, "Failed to parse OpenStreetMap API response"}
    end
  end
end

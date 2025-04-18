defmodule JetLagServer.Geocoding.Photon do
  @moduledoc """
  Client for the Photon geocoding API.
  https://github.com/komoot/photon
  """

  alias JetLagServer.Geocoding.Structs.Location

  @base_url "https://photon.komoot.io/api"

  # Only include these types of locations
  @allowed_types ["country", "state", "city"]

  @doc """
  Searches for locations matching the given query.

  ## Options

  * `:limit` - Maximum number of results to return (default: 10)
  * `:lang` - Language for results (default: "en")
  """
  @spec search(String.t(), Keyword.t()) :: {:ok, [Location.t()]} | {:error, String.t()}
  def search(query, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)
    lang = Keyword.get(opts, :lang, "en")

    url = "#{@base_url}?q=#{URI.encode(query)}&limit=#{limit}&lang=#{lang}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parse_response(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Photon API returned status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error calling Photon API: #{reason}"}
    end
  end

  # Parse the Photon API response
  defp parse_response(body) do
    body
    |> Jason.decode!()
    |> Map.get("features", [])
    |> Enum.filter(&filter_location_type/1)
    |> Enum.map(&Location.from_photon_feature/1)
  end

  # Filter locations to only include countries, regions/states, and cities
  defp filter_location_type(feature) do
    properties = Map.get(feature, "properties", %{})
    type = get_location_type(properties)
    type in @allowed_types
  end

  # Determine the location type from properties
  defp get_location_type(properties) do
    cond do
      Map.get(properties, "country") != nil && Map.get(properties, "city") == nil &&
          Map.get(properties, "state") == nil ->
        "country"

      Map.get(properties, "state") != nil && Map.get(properties, "city") == nil ->
        "state"

      Map.get(properties, "city") != nil ->
        "city"

      true ->
        "other"
    end
  end
end

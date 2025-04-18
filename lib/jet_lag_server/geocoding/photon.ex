defmodule JetLagServer.Geocoding.Photon do
  @moduledoc """
  Client for the Photon geocoding API.
  https://github.com/komoot/photon
  """

  alias JetLagServer.Geocoding.Structs.Location

  @base_url "https://photon.komoot.io/api"

  # Mapping of our location types to Photon API layer values
  @layer_mapping %{
    "country" => "country",
    "state" => "state",
    "city" => "city"
  }

  @doc """
  Searches for locations matching the given query.

  ## Options

  * `:limit` - Maximum number of results to return (default: 10)
  * `:lang` - Language for results (default: "en")
  * `:layers` - List of location types to include (default: ["country", "state", "city"])
  """
  @spec search(String.t(), Keyword.t()) :: {:ok, [Location.t()]} | {:error, String.t()}
  def search(query, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)
    lang = Keyword.get(opts, :lang, "en")
    layers = Keyword.get(opts, :layers, ["country", "state", "city"])

    # Build the URL with layer filters
    url = build_url(query, limit, lang, layers)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, parse_response(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Photon API returned status code #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Error calling Photon API: #{reason}"}
    end
  end

  # Build the URL with layer filters
  defp build_url(query, limit, lang, layers) do
    # Convert our layer types to Photon API layer values
    layer_params =
      layers
      |> Enum.map(fn layer -> Map.get(@layer_mapping, layer, layer) end)
      |> Enum.map(fn layer -> "&layer=#{layer}" end)
      |> Enum.join("")

    "#{@base_url}?q=#{URI.encode(query)}&limit=#{limit}&lang=#{lang}#{layer_params}"
  end

  # Parse the Photon API response
  defp parse_response(body) do
    body
    |> Jason.decode!()
    |> Map.get("features", [])
    |> Enum.map(&Location.from_photon_feature/1)
  end
end

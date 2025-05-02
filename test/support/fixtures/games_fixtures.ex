defmodule JetLagServer.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `JetLagServer.Games` context.
  """

  @doc """
  Generate a valid cached boundary.
  """
  def cached_boundary_fixture(attrs \\ %{}) do
    # Generate a unique osm_id if not provided
    attrs =
      if Map.has_key?(attrs, :osm_id) || Map.has_key?(attrs, "osm_id") do
        attrs
      else
        random_id = :rand.uniform(999_999_999) |> to_string()
        Map.put(attrs, :osm_id, random_id)
      end

    # Create a boundary struct
    boundary = %JetLagServer.Geocoding.Structs.Boundary{
      name: "Madrid",
      type: "city",
      osm_id: Map.get(attrs, :osm_id) || Map.get(attrs, "osm_id"),
      osm_type: Map.get(attrs, :osm_type, "way"),
      coordinates: [-3.7038, 40.4168],
      boundaries: %{
        "type" => "Polygon",
        "coordinates" => [[[-3.8, 40.3], [-3.8, 40.5], [-3.6, 40.5], [-3.6, 40.3], [-3.8, 40.3]]]
      }
    }

    # Encode the boundary to JSON
    data = Jason.encode!(boundary)

    # Create the cached boundary
    {:ok, cached} =
      %JetLagServer.Geocoding.CachedBoundary{}
      |> JetLagServer.Geocoding.CachedBoundary.changeset(%{
        osm_type: Map.get(attrs, :osm_type, "way"),
        osm_id: Map.get(attrs, :osm_id) || Map.get(attrs, "osm_id"),
        data: data
      })
      |> JetLagServer.Repo.insert()

    cached
  end

  @doc """
  Generate valid game settings.
  """
  def game_settings_fixture(attrs \\ %{}) do
    {:ok, settings} =
      attrs
      |> Enum.into(%{
        units: :iso,
        game_size: :medium,
        hiding_zones: ["bus_stops", "local_trains"],
        game_duration: 1,
        day_start_time: "09:00",
        day_end_time: "18:00"
      })
      |> JetLagServer.Games.create_game_settings()

    settings
  end

  @doc """
  Generate a game with a location, settings, and a creator player.
  """
  def game_fixture(attrs \\ %{}) do
    # Create a cached boundary first if not provided
    cached = Map.get(attrs, :cached_boundary) || cached_boundary_fixture()

    # Create a game with default values
    {:ok, game} =
      JetLagServer.Games.create_game(%{
        location_id: Map.get(attrs, :location_id, "#{cached.osm_type}:#{cached.osm_id}"),
        settings:
          Map.get(attrs, :settings, %{
            units: :iso,
            game_size: :medium,
            hiding_zones: ["bus_stops", "local_trains"],
            game_duration: 1,
            day_start_time: "09:00",
            day_end_time: "18:00"
          }),
        creator:
          Map.get(attrs, :creator, %{
            name: "John Doe"
          })
      })

    game
  end

  @doc """
  Generate a player for a game.
  """
  def player_fixture(game_id, attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        name: "Jane Smith",
        game_id: game_id
      })
      |> JetLagServer.Games.create_player()

    player
  end
end
